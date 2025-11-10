import 'package:equatable/equatable.dart';
import '../../models/user.dart' as models;

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final List<models.User> users;
  final Map<String, Map<String, dynamic>> userSalesStats;

  const UserLoaded({
    required this.users,
    required this.userSalesStats,
  });

  @override
  List<Object?> get props => [users, userSalesStats];
}

class UserError extends UserState {
  final String message;
  final List<models.User> users;
  final Map<String, Map<String, dynamic>> userSalesStats;

  const UserError(
    this.message, {
    this.users = const [],
    this.userSalesStats = const {},
  });

  @override
  List<Object?> get props => [message, users, userSalesStats];
}

class UserOperationSuccess extends UserState {
  final List<models.User> users;
  final Map<String, Map<String, dynamic>> userSalesStats;
  final String? message;

  const UserOperationSuccess({
    required this.users,
    required this.userSalesStats,
    this.message,
  });

  @override
  List<Object?> get props => [users, userSalesStats, message];
}
