import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

enum SplashScreenState {
  loading, // Показываем splash screen
  goToLogin, // Не авторизован - на экран логина
  goToHomePicker, // Авторизован но дом не выбран - на пикер дома
  goToHome, // Все готово - на главный экран
  error, // Ошибка при инициализации
}

class SplashScreenCubit extends Cubit<SplashScreenState> {
  SplashScreenCubit() : super(SplashScreenState.loading);

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  /// Основной метод инициализации приложения
  /// Проверяет состояние авторизации и выбора дома
  Future<void> initializeApp() async {
    try {
      emit(SplashScreenState.loading);

      // Минимальное время показа splash screen для UX
      await Future.delayed(const Duration(seconds: 1));

      // Проверяем авторизацию
      final bool isAuthenticated = await _checkAuthentication();

      if (!isAuthenticated) {
        emit(SplashScreenState.goToLogin);
        return;
      }

      // Если авторизован, проверяем выбран ли дом
      final bool isHomeSelected = await _checkHomeSelection();

      if (!isHomeSelected) {
        emit(SplashScreenState.goToHomePicker);
        return;
      }

      // Все проверки пройдены - идем на главный экран
      emit(SplashScreenState.goToHome);
    } catch (e) {
      _errorMessage = 'Ошибка инициализации: $e';
      emit(SplashScreenState.error);
    }
  }

  /// Проверяет состояние авторизации пользователя
  /// Сначала проверяет локальное состояние, затем Google Sign-In
  Future<bool> _checkAuthentication() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (!isLoggedIn) {
        return false;
      }

      // Дополнительная проверка через Google Sign-In
      // Пытаемся сделать "легкую" авторизацию без UI
      return await _attemptSilentGoogleSignIn();
    } catch (e) {
      print('Ошибка проверки авторизации: $e');
      return false;
    }
  }

  /// Попытка тихой авторизации через Google Sign-In
  /// Не показывает UI, только проверяет существующую сессию
  Future<bool> _attemptSilentGoogleSignIn() async {
    try {
      // Инициализируем Google Sign-In Platform
      await GoogleSignInPlatform.instance.init(const InitParameters());

      // Пытаемся сделать легкую авторизацию
      final AuthenticationResults? result = await GoogleSignInPlatform.instance
          .attemptLightweightAuthentication(
            const AttemptLightweightAuthenticationParameters(),
          );

      return result?.user != null;
    } catch (e) {
      print('Ошибка тихой авторизации Google: $e');
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

  /// Метод для повторной инициализации при ошибке
  Future<void> retry() async {
    _errorMessage = '';
    await initializeApp();
  }

  /// Сброс состояния на загрузку
  void reset() {
    _errorMessage = '';
    emit(SplashScreenState.loading);
  }

  /// Принудительный переход на экран логина
  void forceGoToLogin() {
    emit(SplashScreenState.goToLogin);
  }

  /// Принудительный переход на пикер дома
  void forceGoToHomePicker() {
    emit(SplashScreenState.goToHomePicker);
  }

  /// Принудительный переход на главный экран
  void forceGoToHome() {
    emit(SplashScreenState.goToHome);
  }
}
