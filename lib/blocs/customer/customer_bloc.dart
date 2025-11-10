import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../database/drift_database.dart' hide Customer;
import '../../models/customer.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final AppDatabase _db = AppDatabase();
  final Uuid _uuid = const Uuid();

  CustomerBloc() : super(const CustomerInitial()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
    on<GetCustomerEvent>(_onGetCustomer);
    on<AddCustomerEvent>(_onAddCustomer);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
    on<ClearCustomerErrorEvent>(_onClearError);
  }

  Future<void> _onLoadCustomers(
    LoadCustomersEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());

    try {
      final customers = await _db.getAllCustomers(activeOnly: event.activeOnly);
      emit(CustomerLoaded(customers));
    } catch (e) {
      emit(CustomerError(
        'Failed to load customers: ${e.toString()}',
        customers: _getCurrentCustomers(),
      ));
    }
  }

  Future<void> _onGetCustomer(
    GetCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      final customer = await _db.getCustomer(event.id);
      // This event is typically used for lookup, so we don't change the state
      // The result will be used by the calling code
    } catch (e) {
      emit(CustomerError(
        'Failed to get customer: ${e.toString()}',
        customers: _getCurrentCustomers(),
      ));
    }
  }

  Future<void> _onAddCustomer(
    AddCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());

    try {
      final customer = Customer(
        id: _uuid.v4(),
        name: event.name,
        email: event.email,
        phone: event.phone,
        crnNumber: event.crnNumber,
        vatNumber: event.vatNumber,
        saudiAddress: event.saudiAddress,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        needsSync: true,
      );

      await _db.createCustomer(customer);
      final customers = await _db.getAllCustomers(activeOnly: true);

      emit(CustomerOperationSuccess(
        customers: customers,
        message: 'Customer added successfully',
      ));
    } catch (e) {
      emit(CustomerError(
        'Failed to add customer: ${e.toString()}',
        customers: _getCurrentCustomers(),
      ));
    }
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());

    try {
      final updatedCustomer = event.customer.copyWith(
        updatedAt: DateTime.now(),
        needsSync: true,
      );

      await _db.updateCustomer(updatedCustomer);
      final customers = await _db.getAllCustomers(activeOnly: true);

      emit(CustomerOperationSuccess(
        customers: customers,
        message: 'Customer updated successfully',
      ));
    } catch (e) {
      emit(CustomerError(
        'Failed to update customer: ${e.toString()}',
        customers: _getCurrentCustomers(),
      ));
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());

    try {
      await _db.deleteCustomer(event.id);
      final customers = await _db.getAllCustomers(activeOnly: true);

      emit(CustomerOperationSuccess(
        customers: customers,
        message: 'Customer deleted successfully',
      ));
    } catch (e) {
      emit(CustomerError(
        'Failed to delete customer: ${e.toString()}',
        customers: _getCurrentCustomers(),
      ));
    }
  }

  void _onClearError(
    ClearCustomerErrorEvent event,
    Emitter<CustomerState> emit,
  ) {
    if (state is CustomerError) {
      final errorState = state as CustomerError;
      emit(CustomerLoaded(errorState.customers));
    }
  }

  List<Customer> _getCurrentCustomers() {
    if (state is CustomerLoaded) {
      return (state as CustomerLoaded).customers;
    } else if (state is CustomerError) {
      return (state as CustomerError).customers;
    } else if (state is CustomerOperationSuccess) {
      return (state as CustomerOperationSuccess).customers;
    }
    return [];
  }
}
