import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../database/drift_database.dart' hide Product, Sale, SaleItem;
import '../../models/sale.dart';
import 'sale_event.dart';
import 'sale_state.dart';

class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final AppDatabase _db = AppDatabase();
  final Uuid _uuid = const Uuid();

  SaleBloc() : super(const SaleInitial()) {
    on<LoadSalesEvent>(_onLoadSales);
    on<GetSalesByDateRangeEvent>(_onGetSalesByDateRange);
    on<GetCustomerSalesEvent>(_onGetCustomerSales);
    on<GetCustomerStatisticsEvent>(_onGetCustomerStatistics);
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateCartItemQuantity);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<ClearCartEvent>(_onClearCart);
    on<CompleteSaleEvent>(_onCompleteSale);
    on<ReturnSaleEvent>(_onReturnSale);
    on<ClearSaleErrorEvent>(_onClearError);
  }

  Future<void> _onLoadSales(
    LoadSalesEvent event,
    Emitter<SaleState> emit,
  ) async {
    emit(const SaleLoading());

    try {
      final sales = await _db.getAllSales();
      emit(SaleLoaded(
        sales: sales,
        currentSale: _getCurrentSale(),
        cartItems: _getCurrentCartItems(),
      ));
    } catch (e) {
      emit(SaleError(
        'Failed to load sales: ${e.toString()}',
        sales: _getCurrentSales(),
        currentSale: _getCurrentSale(),
        cartItems: _getCurrentCartItems(),
      ));
    }
  }

  Future<void> _onGetSalesByDateRange(
    GetSalesByDateRangeEvent event,
    Emitter<SaleState> emit,
  ) async {
    try {
      final sales = await _db.getSalesByDateRange(event.start, event.end);
      emit(SaleLoaded(
        sales: sales,
        currentSale: _getCurrentSale(),
        cartItems: _getCurrentCartItems(),
      ));
    } catch (e) {
      emit(SaleError(
        'Failed to get sales by date range: ${e.toString()}',
        sales: _getCurrentSales(),
        currentSale: _getCurrentSale(),
        cartItems: _getCurrentCartItems(),
      ));
    }
  }

  Future<void> _onGetCustomerSales(
    GetCustomerSalesEvent event,
    Emitter<SaleState> emit,
  ) async {
    try {
      final sales = await _db.getSalesByCustomer(
        event.customerId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(SaleLoaded(
        sales: sales,
        currentSale: _getCurrentSale(),
        cartItems: _getCurrentCartItems(),
      ));
    } catch (e) {
      emit(SaleError(
        'Failed to get customer sales: ${e.toString()}',
        sales: _getCurrentSales(),
        currentSale: _getCurrentSale(),
        cartItems: _getCurrentCartItems(),
      ));
    }
  }

  Future<void> _onGetCustomerStatistics(
    GetCustomerStatisticsEvent event,
    Emitter<SaleState> emit,
  ) async {
    try {
      final statistics = await _db.getCustomerSalesStatistics(event.customerId);
      // This event is typically used for lookup, so we don't change the state
      // The result will be used by the calling code
    } catch (e) {
      emit(SaleError(
        'Failed to get customer statistics: ${e.toString()}',
        sales: _getCurrentSales(),
        currentSale: _getCurrentSale(),
        cartItems: _getCurrentCartItems(),
      ));
    }
  }

  void _onAddToCart(
    AddToCartEvent event,
    Emitter<SaleState> emit,
  ) {
    final cartItems = List<SaleItem>.from(_getCurrentCartItems());
    final product = event.product;
    final quantity = event.quantity;
    final vatIncludedInPrice = event.vatIncludedInPrice;
    // Use provided product name or fall back to product.name
    final productName = event.productName ?? product.name;

    final existingIndex = cartItems.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      // Update existing item
      final existingItem = cartItems[existingIndex];
      final newQuantity = existingItem.quantity + quantity;

      // Calculate VAT based on whether it's included or excluded
      final double subtotal, vatAmount, total;
      if (vatIncludedInPrice) {
        // VAT is included in the price
        total = product.price * newQuantity;
        vatAmount = total - (total / (1 + product.vatRate / 100));
        subtotal = total - vatAmount;
      } else {
        // VAT is excluded from the price
        subtotal = product.price * newQuantity;
        vatAmount = (product.price * product.vatRate / 100) * newQuantity;
        total = subtotal + vatAmount;
      }

      cartItems[existingIndex] = SaleItem(
        id: existingItem.id,
        saleId: existingItem.saleId,
        productId: product.id,
        productName: productName,
        unitPrice: product.price,
        quantity: newQuantity,
        vatRate: product.vatRate,
        vatAmount: vatAmount,
        subtotal: subtotal,
        total: total,
      );
    } else {
      // Add new item
      // Calculate VAT based on whether it's included or excluded
      final double subtotal, vatAmount, total;
      if (vatIncludedInPrice) {
        // VAT is included in the price
        total = product.price * quantity;
        vatAmount = total - (total / (1 + product.vatRate / 100));
        subtotal = total - vatAmount;
      } else {
        // VAT is excluded from the price
        subtotal = product.price * quantity;
        vatAmount = (product.price * product.vatRate / 100) * quantity;
        total = subtotal + vatAmount;
      }

      cartItems.add(SaleItem(
        id: _uuid.v4(),
        saleId: '', // Will be set when sale is created
        productId: product.id,
        productName: productName,
        unitPrice: product.price,
        quantity: quantity,
        vatRate: product.vatRate,
        vatAmount: vatAmount,
        subtotal: subtotal,
        total: total,
      ));
    }

    emit(SaleLoaded(
      sales: _getCurrentSales(),
      currentSale: _getCurrentSale(),
      cartItems: cartItems,
    ));
  }

  void _onUpdateCartItemQuantity(
    UpdateCartItemQuantityEvent event,
    Emitter<SaleState> emit,
  ) {
    if (event.newQuantity <= 0) {
      add(RemoveFromCartEvent(event.itemId));
      return;
    }

    final cartItems = List<SaleItem>.from(_getCurrentCartItems());
    final index = cartItems.indexWhere((item) => item.id == event.itemId);

    if (index >= 0) {
      final item = cartItems[index];
      final vatIncludedInPrice = event.vatIncludedInPrice;

      // Calculate VAT based on whether it's included or excluded
      final double subtotal, vatAmount, total;
      if (vatIncludedInPrice) {
        // VAT is included in the price
        total = item.unitPrice * event.newQuantity;
        vatAmount = total - (total / (1 + item.vatRate / 100));
        subtotal = total - vatAmount;
      } else {
        // VAT is excluded from the price
        subtotal = item.unitPrice * event.newQuantity;
        vatAmount = (item.unitPrice * item.vatRate / 100) * event.newQuantity;
        total = subtotal + vatAmount;
      }

      cartItems[index] = SaleItem(
        id: item.id,
        saleId: item.saleId,
        productId: item.productId,
        productName: item.productName,
        unitPrice: item.unitPrice,
        quantity: event.newQuantity,
        vatRate: item.vatRate,
        vatAmount: vatAmount,
        subtotal: subtotal,
        total: total,
      );

      emit(SaleLoaded(
        sales: _getCurrentSales(),
        currentSale: _getCurrentSale(),
        cartItems: cartItems,
      ));
    }
  }

  void _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<SaleState> emit,
  ) {
    final cartItems = List<SaleItem>.from(_getCurrentCartItems());
    cartItems.removeWhere((item) => item.id == event.itemId);

    emit(SaleLoaded(
      sales: _getCurrentSales(),
      currentSale: _getCurrentSale(),
      cartItems: cartItems,
    ));
  }

  void _onClearCart(
    ClearCartEvent event,
    Emitter<SaleState> emit,
  ) {
    emit(SaleLoaded(
      sales: _getCurrentSales(),
      currentSale: null,
      cartItems: const [],
    ));
  }

  Future<void> _onCompleteSale(
    CompleteSaleEvent event,
    Emitter<SaleState> emit,
  ) async {
    final cartItems = _getCurrentCartItems();

    if (cartItems.isEmpty) {
      emit(SaleError(
        'Cart is empty',
        sales: _getCurrentSales(),
        currentSale: _getCurrentSale(),
        cartItems: cartItems,
      ));
      return;
    }

    emit(const SaleLoading());

    try {
      final saleId = _uuid.v4();
      final invoiceNumber = _generateInvoiceNumber();

      // Calculate totals
      final cartSubtotal =
          cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
      final cartVatAmount =
          cartItems.fold(0.0, (sum, item) => sum + item.vatAmount);
      final cartTotal = cartItems.fold(0.0, (sum, item) => sum + item.total);

      // Update sale items with sale ID
      final items = cartItems.map((item) {
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
        customerId: event.customerId,
        cashierId: event.cashierId,
        saleDate: DateTime.now(),
        subtotal: cartSubtotal,
        vatAmount: cartVatAmount,
        totalAmount: cartTotal,
        paidAmount: event.paidAmount,
        changeAmount: event.paidAmount - cartTotal,
        paymentMethod: event.paymentMethod,
        items: items,
        notes: event.notes,
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

      final sales = await _db.getAllSales();

      emit(SaleCompleted(
        sales: sales,
        completedSale: sale,
        cartItems: const [],
      ));
    } catch (e) {
      emit(SaleError(
        'Failed to complete sale: ${e.toString()}',
        sales: _getCurrentSales(),
        currentSale: _getCurrentSale(),
        cartItems: cartItems,
      ));
    }
  }

  Future<void> _onReturnSale(
    ReturnSaleEvent event,
    Emitter<SaleState> emit,
  ) async {
    emit(const SaleLoading());

    try {
      final sale = await _db.getSale(event.saleId);
      if (sale == null) {
        emit(SaleError(
          'Sale not found',
          sales: _getCurrentSales(),
          currentSale: _getCurrentSale(),
          cartItems: _getCurrentCartItems(),
        ));
        return;
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

      final sales = await _db.getAllSales();

      emit(SaleOperationSuccess(
        sales: sales,
        currentSale: _getCurrentSale(),
        cartItems: _getCurrentCartItems(),
        message: 'Sale returned successfully',
      ));
    } catch (e) {
      emit(SaleError(
        'Failed to return sale: ${e.toString()}',
        sales: _getCurrentSales(),
        currentSale: _getCurrentSale(),
        cartItems: _getCurrentCartItems(),
      ));
    }
  }

  void _onClearError(
    ClearSaleErrorEvent event,
    Emitter<SaleState> emit,
  ) {
    if (state is SaleError) {
      final errorState = state as SaleError;
      emit(SaleLoaded(
        sales: errorState.sales,
        currentSale: errorState.currentSale,
        cartItems: errorState.cartItems,
      ));
    }
  }

  String _generateInvoiceNumber() {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyyMMdd');
    final timeFormat = DateFormat('HHmmss');
    return 'INV-${dateFormat.format(now)}-${timeFormat.format(now)}';
  }

  List<Sale> _getCurrentSales() {
    if (state is SaleLoaded) {
      return (state as SaleLoaded).sales;
    } else if (state is SaleError) {
      return (state as SaleError).sales;
    } else if (state is SaleCompleted) {
      return (state as SaleCompleted).sales;
    } else if (state is SaleOperationSuccess) {
      return (state as SaleOperationSuccess).sales;
    }
    return [];
  }

  Sale? _getCurrentSale() {
    if (state is SaleLoaded) {
      return (state as SaleLoaded).currentSale;
    } else if (state is SaleError) {
      return (state as SaleError).currentSale;
    } else if (state is SaleCompleted) {
      return (state as SaleCompleted).completedSale;
    } else if (state is SaleOperationSuccess) {
      return (state as SaleOperationSuccess).currentSale;
    }
    return null;
  }

  List<SaleItem> _getCurrentCartItems() {
    if (state is SaleLoaded) {
      return (state as SaleLoaded).cartItems;
    } else if (state is SaleError) {
      return (state as SaleError).cartItems;
    } else if (state is SaleCompleted) {
      return (state as SaleCompleted).cartItems;
    } else if (state is SaleOperationSuccess) {
      return (state as SaleOperationSuccess).cartItems;
    }
    return [];
  }
}
