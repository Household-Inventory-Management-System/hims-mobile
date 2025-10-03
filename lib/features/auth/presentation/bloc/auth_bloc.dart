import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hims/core/services/auth_service.dart';
import 'package:hims/core/models/hims_user.dart';
import 'package:equatable/equatable.dart';

// ======================== EVENTS ========================
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Событие проверки статуса авторизации при запуске
class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

/// Событие авторизации через Google
class AuthSignInWithGoogle extends AuthEvent {
  const AuthSignInWithGoogle();
}

/// Событие авторизации через email/пароль
class AuthSignInWithEmail extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmail({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Событие регистрации через email/пароль
class AuthSignUpWithEmail extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthSignUpWithEmail({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

/// Событие выхода из аккаунта
class AuthSignOut extends AuthEvent {
  const AuthSignOut();
}

/// Событие очистки ошибки
class AuthClearError extends AuthEvent {
  const AuthClearError();
}

// ======================== STATES ========================
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние загрузки
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Состояние загрузки (процесс авторизации)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Состояние успешной авторизации
class AuthAuthenticated extends AuthState {
  final HimsUser? user;
  final String displayName;

  const AuthAuthenticated({this.user, this.displayName = ''});

  @override
  List<Object?> get props => [user, displayName];
}

/// Состояние отсутствия авторизации
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Состояние ошибки авторизации
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// ======================== BLOC ========================
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = AuthService();

  AuthBloc() : super(const AuthInitial()) {
    // Регистрация обработчиков событий
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthSignInWithGoogle>(_onSignInWithGoogle);
    on<AuthSignInWithEmail>(_onSignInWithEmail);
    on<AuthSignUpWithEmail>(_onSignUpWithEmail);
    on<AuthSignOut>(_onSignOut);
    on<AuthClearError>(_onClearError);
  }

  // Getters для доступа к данным из сервиса
  bool get isAuthorized => _authService.isAuthorized;
  String get contactText => _authService.contactText;
  String get errorMessage => _authService.errorMessage;
  HimsUser? get currentUser => _authService.currentUser;

  /// Обработчик события проверки статуса авторизации
  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final isAuthenticated = await _authService.checkAuthenticationStatus();

      if (isAuthenticated) {
        emit(
          AuthAuthenticated(
            user: _authService.currentUser,
            displayName: _authService.contactText,
          ),
        );
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Ошибка проверки авторизации: $e'));
    }
  }

  /// Обработчик события авторизации через Google
  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final success = await _authService.signInWithGoogle();

      if (success) {
        emit(
          AuthAuthenticated(
            user: _authService.currentUser,
            displayName: _authService.contactText,
          ),
        );
      } else {
        final errorMsg =
            _authService.errorMessage.isNotEmpty
                ? _authService.errorMessage
                : 'Не удалось авторизоваться через Google';
        _onSignOut(const AuthSignOut(), emit);
        emit(AuthError(errorMsg));
      }
    } catch (e) {
      emit(AuthError('Ошибка Google авторизации: $e'));
    }
  }

  /// Обработчик события авторизации через email/пароль
  Future<void> _onSignInWithEmail(
    AuthSignInWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final success = await _authService.signInWithEmail(
        event.email,
        event.password,
      );

      if (success) {
        emit(
          AuthAuthenticated(
            user: _authService.currentUser,
            displayName: _authService.contactText,
          ),
        );
      } else {
        final errorMsg =
            _authService.errorMessage.isNotEmpty
                ? _authService.errorMessage
                : 'Не удалось войти с указанными данными';
        emit(AuthError(errorMsg));
      }
    } catch (e) {
      emit(AuthError('Ошибка входа: $e'));
    }
  }

  /// Обработчик события регистрации через email/пароль
  Future<void> _onSignUpWithEmail(
    AuthSignUpWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final success = await _authService.signUpWithEmail(
        event.email,
        event.password,
        event.name,
      );

      if (success) {
        emit(
          AuthAuthenticated(
            user: _authService.currentUser,
            displayName: _authService.contactText,
          ),
        );
      } else {
        final errorMsg =
            _authService.errorMessage.isNotEmpty
                ? _authService.errorMessage
                : 'Не удалось зарегистрироваться';
        emit(AuthError(errorMsg));
      }
    } catch (e) {
      emit(AuthError('Ошибка регистрации: $e'));
    }
  }

  /// Обработчик события выхода из аккаунта
  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final success = await _authService.signOut();

      if (success) {
        emit(const AuthUnauthenticated());
      } else {
        // Даже при ошибке считаем, что пользователь вышел
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      // При ошибке выхода все равно переходим в неавторизованное состояние
      emit(const AuthUnauthenticated());
    }
  }

  /// Обработчик события очистки ошибки
  Future<void> _onClearError(
    AuthClearError event,
    Emitter<AuthState> emit,
  ) async {
    _authService.clearError();

    // Возвращаемся к состоянию без авторизации
    emit(const AuthUnauthenticated());
  }

  // Legacy методы для совместимости с существующим кодом
  Future<void> checkAuthenticationStatus() async {
    add(const AuthCheckStatus());
  }

  Future<void> signInWithGoogle() async {
    add(const AuthSignInWithGoogle());
  }

  Future<void> handleSignIn() async {
    add(const AuthSignInWithGoogle());
  }

  Future<void> handleSignOut() async {
    add(const AuthSignOut());
  }

  void clearError() {
    add(const AuthClearError());
  }

  // Новые методы для работы с email авторизацией
  Future<void> signInWithEmail(String email, String password) async {
    add(AuthSignInWithEmail(email: email, password: password));
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    add(AuthSignUpWithEmail(email: email, password: password, name: name));
  }
}
