import 'package:equatable/equatable.dart';
import '../../models/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  bool get isLoggedIn => true;
  bool get isAdmin => user.role == UserRole.admin;
  bool get isCashier => user.role == UserRole.cashier;

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();

  bool get isLoggedIn => false;
}

class AuthError extends AuthState {
  final String message;
  final User? user;

  const AuthError(this.message, {this.user});

  bool get isLoggedIn => user != null;
  bool get isAdmin => user?.role == UserRole.admin;
  bool get isCashier => user?.role == UserRole.cashier;

  @override
  List<Object?> get props => [message, user];
}
