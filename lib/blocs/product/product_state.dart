import 'package:equatable/equatable.dart';
import '../../models/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<String> categories;

  const ProductLoaded({
    required this.products,
    required this.categories,
  });

  @override
  List<Object?> get props => [products, categories];
}

class ProductError extends ProductState {
  final String message;
  final List<Product> products;
  final List<String> categories;

  const ProductError(
    this.message, {
    this.products = const [],
    this.categories = const [],
  });

  @override
  List<Object?> get props => [message, products, categories];
}

class ProductOperationSuccess extends ProductState {
  final List<Product> products;
  final List<String> categories;
  final String? message;

  const ProductOperationSuccess({
    required this.products,
    required this.categories,
    this.message,
  });

  @override
  List<Object?> get props => [products, categories, message];
}
