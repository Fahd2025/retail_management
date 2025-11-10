import 'package:equatable/equatable.dart';
import '../../models/sale.dart';

abstract class SaleState extends Equatable {
  const SaleState();

  @override
  List<Object?> get props => [];
}

class SaleInitial extends SaleState {
  const SaleInitial();
}

class SaleLoading extends SaleState {
  const SaleLoading();
}

class SaleLoaded extends SaleState {
  final List<Sale> sales;
  final Sale? currentSale;
  final List<SaleItem> cartItems;

  const SaleLoaded({
    required this.sales,
    this.currentSale,
    required this.cartItems,
  });

  double get cartSubtotal =>
      cartItems.fold(0, (sum, item) => sum + item.subtotal);
  double get cartVatAmount =>
      cartItems.fold(0, (sum, item) => sum + item.vatAmount);
  double get cartTotal => cartItems.fold(0, (sum, item) => sum + item.total);
  int get cartItemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [sales, currentSale, cartItems];
}

class SaleError extends SaleState {
  final String message;
  final List<Sale> sales;
  final Sale? currentSale;
  final List<SaleItem> cartItems;

  const SaleError(
    this.message, {
    this.sales = const [],
    this.currentSale,
    this.cartItems = const [],
  });

  double get cartSubtotal =>
      cartItems.fold(0, (sum, item) => sum + item.subtotal);
  double get cartVatAmount =>
      cartItems.fold(0, (sum, item) => sum + item.vatAmount);
  double get cartTotal => cartItems.fold(0, (sum, item) => sum + item.total);
  int get cartItemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [message, sales, currentSale, cartItems];
}

class SaleCompleted extends SaleState {
  final List<Sale> sales;
  final Sale completedSale;
  final List<SaleItem> cartItems;

  const SaleCompleted({
    required this.sales,
    required this.completedSale,
    this.cartItems = const [],
  });

  @override
  List<Object?> get props => [sales, completedSale, cartItems];
}

class SaleOperationSuccess extends SaleState {
  final List<Sale> sales;
  final Sale? currentSale;
  final List<SaleItem> cartItems;
  final String? message;

  const SaleOperationSuccess({
    required this.sales,
    this.currentSale,
    required this.cartItems,
    this.message,
  });

  double get cartSubtotal =>
      cartItems.fold(0, (sum, item) => sum + item.subtotal);
  double get cartVatAmount =>
      cartItems.fold(0, (sum, item) => sum + item.vatAmount);
  double get cartTotal => cartItems.fold(0, (sum, item) => sum + item.total);
  int get cartItemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [sales, currentSale, cartItems, message];
}
