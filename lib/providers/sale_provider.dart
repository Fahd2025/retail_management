import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../models/product.dart';
import '../database/drift_database.dart' hide Product, Sale, SaleItem;

class SaleProvider with ChangeNotifier {
  final AppDatabase _db = AppDatabase();
  final Uuid _uuid = const Uuid();

  List<Sale> _sales = [];
  Sale? _currentSale;
  List<SaleItem> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Sale> get sales => _sales;
  Sale? get currentSale => _currentSale;
  List<SaleItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get cartSubtotal => _cartItems.fold(0, (sum, item) => sum + item.subtotal);
  double get cartVatAmount => _cartItems.fold(0, (sum, item) => sum + item.vatAmount);
  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.total);
  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  Future<void> loadSales() async {
    _isLoading = true;
    notifyListeners();

    try {
      _sales = await _db.getAllSales();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load sales: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
    return await _db.getSalesByDateRange(start, end);
  }

  Future<List<Sale>> getCustomerSales(String customerId, {DateTime? startDate, DateTime? endDate}) async {
    return await _db.getSalesByCustomer(customerId, startDate: startDate, endDate: endDate);
  }

  Future<Map<String, dynamic>> getCustomerStatistics(String customerId) async {
    return await _db.getCustomerSalesStatistics(customerId);
  }

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      // Update existing item
      final existingItem = _cartItems[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      final subtotal = product.price * newQuantity;
      final vatAmount = (product.price * product.vatRate / 100) * newQuantity;
      final total = subtotal + vatAmount;

      _cartItems[existingIndex] = SaleItem(
        id: existingItem.id,
        saleId: existingItem.saleId,
        productId: product.id,
        productName: product.name,
        unitPrice: product.price,
        quantity: newQuantity,
        vatRate: product.vatRate,
        vatAmount: vatAmount,
        subtotal: subtotal,
        total: total,
      );
    } else {
      // Add new item
      final subtotal = product.price * quantity;
      final vatAmount = (product.price * product.vatRate / 100) * quantity;
      final total = subtotal + vatAmount;

      _cartItems.add(SaleItem(
        id: _uuid.v4(),
        saleId: '', // Will be set when sale is created
        productId: product.id,
        productName: product.name,
        unitPrice: product.price,
        quantity: quantity,
        vatRate: product.vatRate,
        vatAmount: vatAmount,
        subtotal: subtotal,
        total: total,
      ));
    }

    notifyListeners();
  }

  void updateCartItemQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(itemId);
      return;
    }

    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      final item = _cartItems[index];
      final subtotal = item.unitPrice * newQuantity;
      final vatAmount = (item.unitPrice * item.vatRate / 100) * newQuantity;
      final total = subtotal + vatAmount;

      _cartItems[index] = SaleItem(
        id: item.id,
        saleId: item.saleId,
        productId: item.productId,
        productName: item.productName,
        unitPrice: item.unitPrice,
        quantity: newQuantity,
        vatRate: item.vatRate,
        vatAmount: vatAmount,
        subtotal: subtotal,
        total: total,
      );

      notifyListeners();
    }
  }

  void removeFromCart(String itemId) {
    _cartItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _currentSale = null;
    notifyListeners();
  }

  Future<Sale?> completeSale({
    required String cashierId,
    String? customerId,
    required double paidAmount,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String? notes,
  }) async {
    if (_cartItems.isEmpty) {
      _errorMessage = 'Cart is empty';
      notifyListeners();
      return null;
    }

    try {
      final saleId = _uuid.v4();
      final invoiceNumber = _generateInvoiceNumber();

      // Update sale items with sale ID
      final items = _cartItems.map((item) {
        return SaleItem(
          id: item.id,
          saleId: saleId,
          productId: item.productId,
          productName: item.productName,
          unitPrice: item.unitPrice,
          quantity: item.quantity,
          vatRate: item.vatRate,
          vatAmount: item.vatAmount,
          subtotal: item.subtotal,
          total: item.total,
        );
      }).toList();

      final sale = Sale(
        id: saleId,
        invoiceNumber: invoiceNumber,
        customerId: customerId,
        cashierId: cashierId,
        saleDate: DateTime.now(),
        subtotal: cartSubtotal,
        vatAmount: cartVatAmount,
        totalAmount: cartTotal,
        paidAmount: paidAmount,
        changeAmount: paidAmount - cartTotal,
        paymentMethod: paymentMethod,
        items: items,
        notes: notes,
        needsSync: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.createSale(sale);

      // Update product quantities
      for (var item in items) {
        final product = await _db.getProduct(item.productId);
        if (product != null) {
          final updatedProduct = product.copyWith(
            quantity: product.quantity - item.quantity,
            updatedAt: DateTime.now(),
            needsSync: true,
          );
          await _db.updateProduct(updatedProduct);
        }
      }

      _currentSale = sale;
      clearCart();
      await loadSales();

      return sale;
    } catch (e) {
      _errorMessage = 'Failed to complete sale: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<bool> returnSale(String saleId, String cashierId) async {
    try {
      final sale = await _db.getSale(saleId);
      if (sale == null) {
        _errorMessage = 'Sale not found';
        notifyListeners();
        return false;
      }

      // Update sale status to returned
      final updatedSale = sale.copyWith(
        status: SaleStatus.returned,
        updatedAt: DateTime.now(),
        needsSync: true,
      );
      await _db.updateSale(updatedSale);

      // Restore product quantities
      for (var item in sale.items) {
        final product = await _db.getProduct(item.productId);
        if (product != null) {
          final updatedProduct = product.copyWith(
            quantity: product.quantity + item.quantity,
            updatedAt: DateTime.now(),
            needsSync: true,
          );
          await _db.updateProduct(updatedProduct);
        }
      }

      await loadSales();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to return sale: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  String _generateInvoiceNumber() {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyyMMdd');
    final timeFormat = DateFormat('HHmmss');
    return 'INV-${dateFormat.format(now)}-${timeFormat.format(now)}';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
