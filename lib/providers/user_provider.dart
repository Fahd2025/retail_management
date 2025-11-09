import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../database/drift_database.dart';

class UserProvider with ChangeNotifier {
  final AppDatabase _db = AppDatabase();
  final Uuid _uuid = const Uuid();

  List<User> _users = [];
  Map<String, Map<String, dynamic>> _userSalesStats = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<User> get users => _users;
  Map<String, Map<String, dynamic>> get userSalesStats => _userSalesStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _db.getAllUsers();

      // Load sales statistics for each user
      _userSalesStats.clear();
      for (var user in _users) {
        final stats = await _db.getUserSalesStats(user.id);
        _userSalesStats[user.id] = stats;
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load users: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<User?> getUserById(String id) async {
    return await _db.getUserById(id);
  }

  Future<bool> addUser({
    required String username,
    required String password,
    required String fullName,
    required UserRole role,
    bool isActive = true,
  }) async {
    try {
      final user = User(
        id: _uuid.v4(),
        username: username,
        password: password,
        fullName: fullName,
        role: role,
        isActive: isActive,
        createdAt: DateTime.now(),
      );

      await _db.createUser(user);
      await loadUsers();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add user: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(User user) async {
    try {
      await _db.updateUser(user);
      await loadUsers();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update user: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      await _db.deleteUser(id);
      await loadUsers();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete user: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
