import 'package:equatable/equatable.dart';
import '../../models/user.dart' as models;

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsersEvent extends UserEvent {
  const LoadUsersEvent();
}

class GetUserByIdEvent extends UserEvent {
  final String id;

  const GetUserByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class AddUserEvent extends UserEvent {
  final String username;
  final String password;
  final String fullName;
  final models.UserRole role;
  final bool isActive;

  const AddUserEvent({
    required this.username,
    required this.password,
    required this.fullName,
    required this.role,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [username, password, fullName, role, isActive];
}

class UpdateUserEvent extends UserEvent {
  final models.User user;

  const UpdateUserEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class DeleteUserEvent extends UserEvent {
  final String id;

  const DeleteUserEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearUserErrorEvent extends UserEvent {
  const ClearUserErrorEvent();
}
