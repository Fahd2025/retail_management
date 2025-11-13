import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../database/drift_database.dart' hide Product;
import '../../models/product.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final AppDatabase _db = AppDatabase();
  final Uuid _uuid = const Uuid();

  ProductBloc() : super(const ProductInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<GetProductsByCategoryEvent>(_onGetProductsByCategory);
    on<GetProductByBarcodeEvent>(_onGetProductByBarcode);
    on<AddProductEvent>(_onAddProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<UpdateStockEvent>(_onUpdateStock);
    on<ClearProductErrorEvent>(_onClearError);
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    try {
      final products = await _db.getAllProducts(activeOnly: event.activeOnly);
      final categories = await _db.getProductCategories();

      emit(ProductLoaded(
        products: products,
        categories: categories,
      ));
    } catch (e) {
      emit(ProductError(
        'Failed to load products: ${e.toString()}',
        products: _getCurrentProducts(),
        categories: _getCurrentCategories(),
      ));
    }
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final categories = await _db.getProductCategories();
      final products = _getCurrentProducts();

      emit(ProductLoaded(
        products: products,
        categories: categories,
      ));
    } catch (e) {
      emit(ProductError(
        'Failed to load categories: ${e.toString()}',
        products: _getCurrentProducts(),
        categories: _getCurrentCategories(),
      ));
    }
  }

  Future<void> _onGetProductsByCategory(
    GetProductsByCategoryEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final products = await _db.getProductsByCategory(event.category);
      final categories = _getCurrentCategories();

      emit(ProductLoaded(
        products: products,
        categories: categories,
      ));
    } catch (e) {
      emit(ProductError(
        'Failed to get products by category: ${e.toString()}',
        products: _getCurrentProducts(),
        categories: _getCurrentCategories(),
      ));
    }
  }

  Future<void> _onGetProductByBarcode(
    GetProductByBarcodeEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final product = await _db.getProductByBarcode(event.barcode);
      // This event is typically used for lookup, so we don't change the state
      // The result will be used by the calling code
    } catch (e) {
      emit(ProductError(
        'Failed to get product by barcode: ${e.toString()}',
        products: _getCurrentProducts(),
        categories: _getCurrentCategories(),
      ));
    }
  }

  Future<void> _onAddProduct(
    AddProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    try {
      final product = Product(
        id: _uuid.v4(),
        name: event.name,
        nameAr: event.nameAr,
        description: event.description,
        descriptionAr: event.descriptionAr,
        barcode: event.barcode,
        price: event.price,
        cost: event.cost,
        quantity: event.quantity,
        category: event.category,
        imageUrl: event.imageUrl,
        vatRate: event.vatRate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        needsSync: true,
      );

      await _db.createProduct(product);
      final products = await _db.getAllProducts(activeOnly: true);
      final categories = await _db.getProductCategories();

      emit(ProductOperationSuccess(
        products: products,
        categories: categories,
        message: 'Product added successfully',
      ));
    } catch (e) {
      emit(ProductError(
        'Failed to add product: ${e.toString()}',
        products: _getCurrentProducts(),
        categories: _getCurrentCategories(),
      ));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    try {
      final updatedProduct = event.product.copyWith(
        updatedAt: DateTime.now(),
        needsSync: true,
      );

      await _db.updateProduct(updatedProduct);
      final products = await _db.getAllProducts(activeOnly: true);
      final categories = await _db.getProductCategories();

      emit(ProductOperationSuccess(
        products: products,
        categories: categories,
        message: 'Product updated successfully',
      ));
    } catch (e) {
      emit(ProductError(
        'Failed to update product: ${e.toString()}',
        products: _getCurrentProducts(),
        categories: _getCurrentCategories(),
      ));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    try {
      await _db.deleteProduct(event.id);
      final products = await _db.getAllProducts(activeOnly: true);
      final categories = await _db.getProductCategories();

      emit(ProductOperationSuccess(
        products: products,
        categories: categories,
        message: 'Product deleted successfully',
      ));
    } catch (e) {
      emit(ProductError(
        'Failed to delete product: ${e.toString()}',
        products: _getCurrentProducts(),
        categories: _getCurrentCategories(),
      ));
    }
  }

  Future<void> _onUpdateStock(
    UpdateStockEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    try {
      final products = await _db.getAllProducts(activeOnly: true);
      final product = products.firstWhere((p) => p.id == event.productId);
      final updatedProduct = product.copyWith(
        quantity: event.newQuantity,
        updatedAt: DateTime.now(),
        needsSync: true,
      );

      await _db.updateProduct(updatedProduct);
      final updatedProducts = await _db.getAllProducts(activeOnly: true);
      final categories = await _db.getProductCategories();

      emit(ProductOperationSuccess(
        products: updatedProducts,
        categories: categories,
        message: 'Stock updated successfully',
      ));
    } catch (e) {
      emit(ProductError(
        'Failed to update stock: ${e.toString()}',
        products: _getCurrentProducts(),
        categories: _getCurrentCategories(),
      ));
    }
  }

  void _onClearError(
    ClearProductErrorEvent event,
    Emitter<ProductState> emit,
  ) {
    if (state is ProductError) {
      final errorState = state as ProductError;
      emit(ProductLoaded(
        products: errorState.products,
        categories: errorState.categories,
      ));
    }
  }

  List<Product> _getCurrentProducts() {
    if (state is ProductLoaded) {
      return (state as ProductLoaded).products;
    } else if (state is ProductError) {
      return (state as ProductError).products;
    } else if (state is ProductOperationSuccess) {
      return (state as ProductOperationSuccess).products;
    }
    return [];
  }

  List<String> _getCurrentCategories() {
    if (state is ProductLoaded) {
      return (state as ProductLoaded).categories;
    } else if (state is ProductError) {
      return (state as ProductError).categories;
    } else if (state is ProductOperationSuccess) {
      return (state as ProductOperationSuccess).categories;
    }
    return [];
  }
}
