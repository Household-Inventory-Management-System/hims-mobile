import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hims/core/services/auth_service.dart';
import 'package:equatable/equatable.dart';

// ======================== EVENTS ========================
abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Событие начальной инициализации приложения
class SplashInitializeApp extends SplashEvent {
  const SplashInitializeApp();
}

/// Событие повторной инициализации при ошибке
class SplashRetryInitialization extends SplashEvent {
  const SplashRetryInitialization();
}

/// Событие принудительного перехода на экран логина
class SplashForceGoToLogin extends SplashEvent {
  const SplashForceGoToLogin();
}

/// Событие принудительного перехода на пикер дома
class SplashForceGoToHomePicker extends SplashEvent {
  const SplashForceGoToHomePicker();
}

/// Событие принудительного перехода на главный экран
class SplashForceGoToHome extends SplashEvent {
  const SplashForceGoToHome();
}

// ======================== STATES ========================
abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние загрузки
class SplashInitial extends SplashState {
  const SplashInitial();
}

/// Состояние процесса инициализации
class SplashLoading extends SplashState {
  const SplashLoading();
}

/// Состояние успешной инициализации - переход на экран логина
class SplashNavigateToLogin extends SplashState {
  const SplashNavigateToLogin();
}

/// Состояние успешной инициализации - переход на пикер дома
class SplashNavigateToHomePicker extends SplashState {
  const SplashNavigateToHomePicker();
}

/// Состояние успешной инициализации - переход на главный экран
class SplashNavigateToHome extends SplashState {
  const SplashNavigateToHome();
}

/// Состояние ошибки при инициализации
class SplashError extends SplashState {
  final String message;

  const SplashError(this.message);

  @override
  List<Object?> get props => [message];
}

// ======================== BLOC ========================
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthService _authService = AuthService();

  SplashBloc() : super(const SplashInitial()) {
    // Регистрация обработчиков событий
    on<SplashInitializeApp>(_onInitializeApp);
    on<SplashRetryInitialization>(_onRetryInitialization);
    on<SplashForceGoToLogin>(_onForceGoToLogin);
    on<SplashForceGoToHomePicker>(_onForceGoToHomePicker);
    on<SplashForceGoToHome>(_onForceGoToHome);
  }

  /// Обработчик события инициализации приложения
  Future<void> _onInitializeApp(
    SplashInitializeApp event,
    Emitter<SplashState> emit,
  ) async {
    await _performInitialization(emit);
  }

  /// Обработчик события повторной инициализации
  Future<void> _onRetryInitialization(
    SplashRetryInitialization event,
    Emitter<SplashState> emit,
  ) async {
    await _performInitialization(emit);
  }

  /// Обработчик принудительного перехода на логин
  Future<void> _onForceGoToLogin(
    SplashForceGoToLogin event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashNavigateToLogin());
  }

  /// Обработчик принудительного перехода на пикер дома
  Future<void> _onForceGoToHomePicker(
    SplashForceGoToHomePicker event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashNavigateToHomePicker());
  }

  /// Обработчик принудительного перехода на главный экран
  Future<void> _onForceGoToHome(
    SplashForceGoToHome event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashNavigateToHome());
  }

  /// Основная логика инициализации приложения
  Future<void> _performInitialization(Emitter<SplashState> emit) async {
    try {
      emit(const SplashLoading());

      // Проверяем авторизацию
      final bool isAuthenticated = await _checkAuthentication();

      if (!isAuthenticated) {
        emit(const SplashNavigateToLogin());
        return;
      }

      // Если авторизован, проверяем выбран ли дом
      final bool isHomeSelected = await _checkHomeSelection();

      if (!isHomeSelected) {
        emit(const SplashNavigateToHomePicker());
        return;
      }

      // Все проверки пройдены - идем на главный экран
      emit(const SplashNavigateToHome());
    } catch (e) {
      emit(SplashError('Ошибка инициализации: $e'));
    }
  }

  /// Проверяет состояние авторизации пользователя через AuthService
  Future<bool> _checkAuthentication() async {
    try {
      return await _authService.checkAuthenticationStatus();
    } catch (e) {
      print('Ошибка проверки авторизации: $e');
      return false;
    }
  }

  /// Проверяет выбран ли дом пользователем
  Future<bool> _checkHomeSelection() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Проверяем есть ли сохраненный ID дома
      final String? selectedHomeId = prefs.getString('selectedHomeId');
      final String? selectedHomeName = prefs.getString('selectedHomeName');

      return selectedHomeId != null && selectedHomeName != null;
    } catch (e) {
      print('Ошибка проверки выбора дома: $e');
      return false;
    }
  }
}
