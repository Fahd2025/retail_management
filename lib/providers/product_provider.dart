import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../database/database_helper.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  List<Product> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProducts({bool activeOnly = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _db.getAllProducts(activeOnly: activeOnly);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load products: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _db.getProductCategories();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load categories: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    return await _db.getProductsByCategory(category);
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    return await _db.getProductByBarcode(barcode);
  }

  Future<bool> addProduct({
    required String name,
    String? description,
    required String barcode,
    required double price,
    required double cost,
    int quantity = 0,
    required String category,
    String? imageUrl,
    double vatRate = 15.0,
  }) async {
    try {
      final product = Product(
        id: _uuid.v4(),
        name: name,
        description: description,
        barcode: barcode,
        price: price,
        cost: cost,
        quantity: quantity,
        category: category,
        imageUrl: imageUrl,
        vatRate: vatRate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        needsSync: true,
      );

      await _db.createProduct(product);
      await loadProducts(activeOnly: true);
      await loadCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add product: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      final updatedProduct = product.copyWith(
        updatedAt: DateTime.now(),
        needsSync: true,
      );

      await _db.updateProduct(updatedProduct);
      await loadProducts(activeOnly: true);
      await loadCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update product: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _db.deleteProduct(id);
      await loadProducts(activeOnly: true);
      await loadCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete product: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStock(String productId, int newQuantity) async {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      final updatedProduct = product.copyWith(
        quantity: newQuantity,
        updatedAt: DateTime.now(),
        needsSync: true,
      );

      await _db.updateProduct(updatedProduct);
      await loadProducts(activeOnly: true);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update stock: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
