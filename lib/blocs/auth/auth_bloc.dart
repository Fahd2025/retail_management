import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = AuthService();

  AuthBloc() : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<ClearErrorEvent>(_onClearError);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final user = await _authService.getCurrentUser();

    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authService.login(event.username, event.password);

      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthError('Invalid username or password'));
      }
    } catch (e) {
      emit(AuthError('Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.logout();
    emit(const Unauthenticated());
  }

  void _onClearError(
    ClearErrorEvent event,
    Emitter<AuthState> emit,
  ) {
    // If we have an error state with a user, return to authenticated
    // Otherwise, return to unauthenticated
    if (state is AuthError) {
      final errorState = state as AuthError;
      if (errorState.user != null) {
        emit(Authenticated(errorState.user!));
      } else {
        emit(const Unauthenticated());
      }
    }
  }
}
