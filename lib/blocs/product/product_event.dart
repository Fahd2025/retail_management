import 'package:equatable/equatable.dart';
import '../../models/product.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsEvent extends ProductEvent {
  final bool activeOnly;

  const LoadProductsEvent({this.activeOnly = false});

  @override
  List<Object?> get props => [activeOnly];
}

class LoadCategoriesEvent extends ProductEvent {
  const LoadCategoriesEvent();
}

class GetProductsByCategoryEvent extends ProductEvent {
  final String category;

  const GetProductsByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class GetProductByBarcodeEvent extends ProductEvent {
  final String barcode;

  const GetProductByBarcodeEvent(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class AddProductEvent extends ProductEvent {
  final String name;
  final String? nameAr;
  final String? description;
  final String? descriptionAr;
  final String barcode;
  final double price;
  final double cost;
  final int quantity;
  final String category;
  final String? imageUrl;
  final double vatRate;

  const AddProductEvent({
    required this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    required this.barcode,
    required this.price,
    required this.cost,
    this.quantity = 0,
    required this.category,
    this.imageUrl,
    this.vatRate = 15.0,
  });

  @override
  List<Object?> get props => [
        name,
        nameAr,
        description,
        descriptionAr,
        barcode,
        price,
        cost,
        quantity,
        category,
        imageUrl,
        vatRate,
      ];
}

class UpdateProductEvent extends ProductEvent {
  final Product product;

  const UpdateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProductEvent extends ProductEvent {
  final String id;

  const DeleteProductEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateStockEvent extends ProductEvent {
  final String productId;
  final int newQuantity;

  const UpdateStockEvent(this.productId, this.newQuantity);

  @override
  List<Object?> get props => [productId, newQuantity];
}

class ClearProductErrorEvent extends ProductEvent {
  const ClearProductErrorEvent();
}
