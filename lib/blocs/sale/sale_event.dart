import 'package:equatable/equatable.dart';
import '../../models/product.dart';
import '../../models/sale.dart';

abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object?> get props => [];
}

class LoadSalesEvent extends SaleEvent {
  const LoadSalesEvent();
}

class GetSalesByDateRangeEvent extends SaleEvent {
  final DateTime start;
  final DateTime end;

  const GetSalesByDateRangeEvent(this.start, this.end);

  @override
  List<Object?> get props => [start, end];
}

class GetCustomerSalesEvent extends SaleEvent {
  final String customerId;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetCustomerSalesEvent(
    this.customerId, {
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [customerId, startDate, endDate];
}

class GetCustomerStatisticsEvent extends SaleEvent {
  final String customerId;

  const GetCustomerStatisticsEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class AddToCartEvent extends SaleEvent {
  final Product product;
  final int quantity;
  final bool vatIncludedInPrice;
  final String? productName; // Optional: for localized product names

  const AddToCartEvent(
    this.product, {
    this.quantity = 1,
    this.vatIncludedInPrice = true,
    this.productName,
  });

  @override
  List<Object?> get props => [product, quantity, vatIncludedInPrice, productName];
}

class UpdateCartItemQuantityEvent extends SaleEvent {
  final String itemId;
  final int newQuantity;
  final bool vatIncludedInPrice;

  const UpdateCartItemQuantityEvent(this.itemId, this.newQuantity, {this.vatIncludedInPrice = true});

  @override
  List<Object?> get props => [itemId, newQuantity, vatIncludedInPrice];
}

class RemoveFromCartEvent extends SaleEvent {
  final String itemId;

  const RemoveFromCartEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class ClearCartEvent extends SaleEvent {
  const ClearCartEvent();
}

class CompleteSaleEvent extends SaleEvent {
  final String cashierId;
  final String? customerId;
  final double paidAmount;
  final PaymentMethod paymentMethod;
  final String? notes;

  const CompleteSaleEvent({
    required this.cashierId,
    this.customerId,
    required this.paidAmount,
    this.paymentMethod = PaymentMethod.cash,
    this.notes,
  });

  @override
  List<Object?> get props => [
        cashierId,
        customerId,
        paidAmount,
        paymentMethod,
        notes,
      ];
}

class ReturnSaleEvent extends SaleEvent {
  final String saleId;
  final String cashierId;

  const ReturnSaleEvent(this.saleId, this.cashierId);

  @override
  List<Object?> get props => [saleId, cashierId];
}

class ClearSaleErrorEvent extends SaleEvent {
  const ClearSaleErrorEvent();
}
