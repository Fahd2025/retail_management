import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/customer.dart';
import '../database/database_helper.dart';

class CustomerProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCustomers({bool activeOnly = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await _db.getAllCustomers(activeOnly: activeOnly);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load customers: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Customer?> getCustomer(String id) async {
    return await _db.getCustomer(id);
  }

  Future<bool> addCustomer({
    required String name,
    String? email,
    String? phone,
    String? crnNumber,
    String? vatNumber,
    SaudiAddress? saudiAddress,
  }) async {
    try {
      final customer = Customer(
        id: _uuid.v4(),
        name: name,
        email: email,
        phone: phone,
        crnNumber: crnNumber,
        vatNumber: vatNumber,
        saudiAddress: saudiAddress,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        needsSync: true,
      );

      await _db.createCustomer(customer);
      await loadCustomers(activeOnly: true);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add customer: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCustomer(Customer customer) async {
    try {
      final updatedCustomer = customer.copyWith(
        updatedAt: DateTime.now(),
        needsSync: true,
      );

      await _db.updateCustomer(updatedCustomer);
      await loadCustomers(activeOnly: true);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update customer: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      await _db.deleteCustomer(id);
      await loadCustomers(activeOnly: true);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete customer: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
