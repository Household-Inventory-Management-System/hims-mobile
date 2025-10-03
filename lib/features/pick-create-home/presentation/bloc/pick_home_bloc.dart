import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hims/core/models/home_model.dart';
import 'package:hims/core/services/firebase_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hims/core/services/auth_service.dart';
import 'package:equatable/equatable.dart';

// ======================== EVENTS ========================
abstract class PickHomeEvent extends Equatable {
  const PickHomeEvent();

  @override
  List<Object?> get props => [];
}

/// Событие загрузки списка доступных домов
class PickHomeLoadHomes extends PickHomeEvent {
  const PickHomeLoadHomes();
}

/// Событие выбора конкретного дома
class PickHomeSelectHome extends PickHomeEvent {
  final Home home;

  const PickHomeSelectHome({required this.home});

  @override
  List<Object?> get props => [home];
}

/// Событие создания нового дома
class PickHomeCreateHome extends PickHomeEvent {
  final String homeName;

  const PickHomeCreateHome({required this.homeName});

  @override
  List<Object?> get props => [homeName];
}

/// Событие выхода из аккаунта
class PickHomeSignOut extends PickHomeEvent {
  const PickHomeSignOut();
}

// ======================== STATES ========================
abstract class PickHomeState extends Equatable {
  const PickHomeState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class PickHomeInitial extends PickHomeState {
  const PickHomeInitial();
}

/// Состояние загрузки домов
class PickHomeLoading extends PickHomeState {
  const PickHomeLoading();
}

class PickHomeHomeCreated extends PickHomeState {
  final String homeId;
  final String homeName;

  const PickHomeHomeCreated({required this.homeId, required this.homeName});

  @override
  List<Object?> get props => [homeId, homeName];
}

/// Состояние успешной загрузки домов
class PickHomeLoaded extends PickHomeState {
  final List<Home> homes;

  const PickHomeLoaded({required this.homes});

  @override
  List<Object?> get props => [homes];
}

/// Состояние успешного выбора дома - переход на главный экран
class PickHomeNavigateToHome extends PickHomeState {
  final String homeId;
  final String homeName;

  const PickHomeNavigateToHome({required this.homeId, required this.homeName});

  @override
  List<Object?> get props => [homeId, homeName];
}

/// Состояние выхода из аккаунта - переход на экран логина
class PickHomeNavigateToLogin extends PickHomeState {
  const PickHomeNavigateToLogin();
}

/// Состояние ошибки
class PickHomeError extends PickHomeState {
  final String message;

  const PickHomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// ======================== BLOC ========================
class PickHomeBloc extends Bloc<PickHomeEvent, PickHomeState> {
  final AuthService _authService = AuthService();

  PickHomeBloc() : super(const PickHomeInitial()) {
    // Регистрация обработчиков событий
    on<PickHomeLoadHomes>(_onLoadHomes);
    on<PickHomeSelectHome>(_onSelectHome);
    on<PickHomeCreateHome>(_onCreateHome);
    on<PickHomeSignOut>(_onSignOut);
  }

  /// Обработчик события загрузки домов
  Future<void> _onLoadHomes(
    PickHomeLoadHomes event,
    Emitter<PickHomeState> emit,
  ) async {
    try {
      emit(const PickHomeLoading());

      final response = await FirebaseDataService().getHomes(
        userId: _authService.currentUser!.id,
      );

      if (response.statusCode == 200) {
        final homes =
            (response.data as List<Map<String, dynamic>>)
                .map((home) => Home.fromFirestore(home))
                .toList();
        emit(PickHomeLoaded(homes: homes));
      } else {
        emit(PickHomeError('Ошибка загрузки домов: ${response.statusCode}'));
      }
    } catch (e) {
      emit(PickHomeError('Ошибка загрузки домов: $e'));
    }
  }

  /// Обработчик события выбора дома
  Future<void> _onSelectHome(
    PickHomeSelectHome event,
    Emitter<PickHomeState> emit,
  ) async {
    try {
      emit(const PickHomeLoading());

      // Сохраняем выбранный дом в SharedPreferences
      await _saveSelectedHome(event.home);

      // Переходим на главный экран
      emit(
        PickHomeNavigateToHome(
          homeId: event.home.id,
          homeName: event.home.name,
        ),
      );
    } catch (e) {
      emit(PickHomeError('Ошибка выбора дома: $e'));
    }
  }

  /// Обработчик события создания дома
  Future<void> _onCreateHome(
    PickHomeCreateHome event,
    Emitter<PickHomeState> emit,
  ) async {
    try {
      emit(const PickHomeLoading());

      final response = await FirebaseDataService().addHome(
        name: event.homeName,
        userId: _authService.currentUser!.id,
      );

      emit(
        PickHomeHomeCreated(
          homeId: response.data as String,
          homeName: event.homeName,
        ),
      );
    } catch (e) {
      emit(PickHomeError('Ошибка создания дома: $e'));
    }
  }

  /// Обработчик события выхода из аккаунта
  Future<void> _onSignOut(
    PickHomeSignOut event,
    Emitter<PickHomeState> emit,
  ) async {
    try {
      emit(const PickHomeLoading());

      // Выход из аккаунта через AuthService
      final success = await _authService.signOut();

      if (success) {
        emit(const PickHomeNavigateToLogin());
      } else {
        emit(
          PickHomeError(
            'Ошибка выхода из аккаунта: ${_authService.errorMessage}',
          ),
        );
      }
    } catch (e) {
      emit(PickHomeError('Ошибка выхода из аккаунта: $e'));
    }
  }

  /// Сохраняет выбранный дом в SharedPreferences
  /// Сохраняет выбранный дом в SharedPreferences
  Future<void> _saveSelectedHome(Home home) async {
    final prefs = await SharedPreferences.getInstance();
    AuthService().currentUser!.home = home;
    await prefs.setString('selectedHomeId', home.id);
    await prefs.setString('selectedHomeName', home.name);
  }
}
