import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../database/drift_database.dart';

class AuthService {
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyRole = 'user_role';

  final AppDatabase _db = AppDatabase();

  Future<User?> login(String username, String password) async {
    final user = await _db.getUserByUsername(username);

    if (user != null && user.password == password && user.isActive) {
      // Update last login time
      final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
      await _db.updateUser(updatedUser);

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, user.id);
      await prefs.setString(_keyUsername, user.username);
      await prefs.setString(_keyRole, user.role.toString());

      return updatedUser;
    }

    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyRole);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_keyUsername);

    if (username != null) {
      return await _db.getUserByUsername(username);
    }

    return null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUserId);
  }

  Future<UserRole?> getCurrentUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString(_keyRole);

    if (roleString != null) {
      return UserRole.values.firstWhere(
        (e) => e.toString() == roleString,
      );
    }

    return null;
  }

  Future<bool> hasPermission(UserRole requiredRole) async {
    final currentRole = await getCurrentUserRole();
    if (currentRole == null) return false;

    // Admin has all permissions
    if (currentRole == UserRole.admin) return true;

    // Check if current role matches required role
    return currentRole == requiredRole;
  }

  Future<bool> isAdmin() async {
    final role = await getCurrentUserRole();
    return role == UserRole.admin;
  }
}
