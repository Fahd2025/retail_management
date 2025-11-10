import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../database/drift_database.dart';
import '../../models/user.dart' as models;
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AppDatabase _db = AppDatabase();
  final Uuid _uuid = const Uuid();

  UserBloc() : super(const UserInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<GetUserByIdEvent>(_onGetUserById);
    on<AddUserEvent>(_onAddUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
    on<ClearUserErrorEvent>(_onClearError);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    try {
      final users = await _db.getAllUsers();

      // Load sales statistics for each user
      final Map<String, Map<String, dynamic>> userSalesStats = {};
      for (var user in users) {
        final stats = await _db.getUserSalesStats(user.id);
        userSalesStats[user.id] = stats;
      }

      emit(UserLoaded(
        users: users,
        userSalesStats: userSalesStats,
      ));
    } catch (e) {
      emit(UserError(
        'Failed to load users: ${e.toString()}',
        users: _getCurrentUsers(),
        userSalesStats: _getCurrentUserSalesStats(),
      ));
    }
  }

  Future<void> _onGetUserById(
    GetUserByIdEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      final user = await _db.getUserById(event.id);
      // This event is typically used for lookup, so we don't change the state
      // The result will be used by the calling code
    } catch (e) {
      emit(UserError(
        'Failed to get user: ${e.toString()}',
        users: _getCurrentUsers(),
        userSalesStats: _getCurrentUserSalesStats(),
      ));
    }
  }

  Future<void> _onAddUser(
    AddUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    try {
      final user = models.User(
        id: _uuid.v4(),
        username: event.username,
        password: event.password,
        fullName: event.fullName,
        role: event.role,
        isActive: event.isActive,
        createdAt: DateTime.now(),
      );

      await _db.createUser(user);

      final users = await _db.getAllUsers();
      final Map<String, Map<String, dynamic>> userSalesStats = {};
      for (var user in users) {
        final stats = await _db.getUserSalesStats(user.id);
        userSalesStats[user.id] = stats;
      }

      emit(UserOperationSuccess(
        users: users,
        userSalesStats: userSalesStats,
        message: 'User added successfully',
      ));
    } catch (e) {
      emit(UserError(
        'Failed to add user: ${e.toString()}',
        users: _getCurrentUsers(),
        userSalesStats: _getCurrentUserSalesStats(),
      ));
    }
  }

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    try {
      await _db.updateUser(event.user);

      final users = await _db.getAllUsers();
      final Map<String, Map<String, dynamic>> userSalesStats = {};
      for (var user in users) {
        final stats = await _db.getUserSalesStats(user.id);
        userSalesStats[user.id] = stats;
      }

      emit(UserOperationSuccess(
        users: users,
        userSalesStats: userSalesStats,
        message: 'User updated successfully',
      ));
    } catch (e) {
      emit(UserError(
        'Failed to update user: ${e.toString()}',
        users: _getCurrentUsers(),
        userSalesStats: _getCurrentUserSalesStats(),
      ));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    try {
      await _db.deleteUser(event.id);

      final users = await _db.getAllUsers();
      final Map<String, Map<String, dynamic>> userSalesStats = {};
      for (var user in users) {
        final stats = await _db.getUserSalesStats(user.id);
        userSalesStats[user.id] = stats;
      }

      emit(UserOperationSuccess(
        users: users,
        userSalesStats: userSalesStats,
        message: 'User deleted successfully',
      ));
    } catch (e) {
      emit(UserError(
        'Failed to delete user: ${e.toString()}',
        users: _getCurrentUsers(),
        userSalesStats: _getCurrentUserSalesStats(),
      ));
    }
  }

  void _onClearError(
    ClearUserErrorEvent event,
    Emitter<UserState> emit,
  ) {
    if (state is UserError) {
      final errorState = state as UserError;
      emit(UserLoaded(
        users: errorState.users,
        userSalesStats: errorState.userSalesStats,
      ));
    }
  }

  List<models.User> _getCurrentUsers() {
    if (state is UserLoaded) {
      return (state as UserLoaded).users;
    } else if (state is UserError) {
      return (state as UserError).users;
    } else if (state is UserOperationSuccess) {
      return (state as UserOperationSuccess).users;
    }
    return [];
  }

  Map<String, Map<String, dynamic>> _getCurrentUserSalesStats() {
    if (state is UserLoaded) {
      return (state as UserLoaded).userSalesStats;
    } else if (state is UserError) {
      return (state as UserError).userSalesStats;
    } else if (state is UserOperationSuccess) {
      return (state as UserOperationSuccess).userSalesStats;
    }
    return {};
  }
}
