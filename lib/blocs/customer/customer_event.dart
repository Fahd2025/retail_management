import 'package:equatable/equatable.dart';
import '../../models/customer.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomersEvent extends CustomerEvent {
  final bool activeOnly;

  const LoadCustomersEvent({this.activeOnly = false});

  @override
  List<Object?> get props => [activeOnly];
}

class GetCustomerEvent extends CustomerEvent {
  final String id;

  const GetCustomerEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class AddCustomerEvent extends CustomerEvent {
  final String name;
  final String? email;
  final String? phone;
  final String? crnNumber;
  final String? vatNumber;
  final SaudiAddress? saudiAddress;

  const AddCustomerEvent({
    required this.name,
    this.email,
    this.phone,
    this.crnNumber,
    this.vatNumber,
    this.saudiAddress,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        crnNumber,
        vatNumber,
        saudiAddress,
      ];
}

class UpdateCustomerEvent extends CustomerEvent {
  final Customer customer;

  const UpdateCustomerEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}

class DeleteCustomerEvent extends CustomerEvent {
  final String id;

  const DeleteCustomerEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearCustomerErrorEvent extends CustomerEvent {
  const ClearCustomerErrorEvent();
}
