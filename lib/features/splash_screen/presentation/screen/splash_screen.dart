import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../bloc/splash_screen_bloc.dart';
import '../../../../app/auto_router.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Запускаем инициализацию приложения через событие
    context.read<SplashBloc>().add(const SplashInitializeApp());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        // Навигация в зависимости от состояния
        if (state is SplashNavigateToLogin) {
          context.router.replace(const LoginRoute());
        } else if (state is SplashNavigateToHomePicker) {
          context.router.replace(const PickHomeRoute());
        } else if (state is SplashNavigateToHome) {
          context.router.replace(const HomeRoute());
        }
        // SplashInitial, SplashLoading, SplashError остаются на splash screen
      },
      child: Scaffold(
        backgroundColor: Colors.blue[300],
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(32.0),
            child: BlocBuilder<SplashBloc, SplashState>(
              builder: (context, state) {
                if (state is SplashInitial || state is SplashLoading) {
                  return _buildLoadingWidget();
                } else if (state is SplashError) {
                  return _buildErrorWidget(context, state.message);
                } else {
                  // Состояния навигации обрабатываются в BlocListener
                  return _buildLoadingWidget();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Виджет загрузки
  Widget _buildLoadingWidget() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Логотип приложения
        Icon(Icons.home, size: 80, color: Colors.blueAccent),
        SizedBox(height: 20),
        Text(
          'HIMS',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Household Inventory Management',
          style: TextStyle(
            fontSize: 14,
            color: Colors.blueGrey,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        ),
        SizedBox(height: 16),
        Text(
          'Загрузка...',
          style: TextStyle(fontSize: 16, color: Colors.blueGrey),
        ),
      ],
    );
  }

  /// Виджет ошибки с возможностью повтора
  Widget _buildErrorWidget(BuildContext context, String errorMessage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
        const SizedBox(height: 20),
        const Text(
          'Ошибка инициализации',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          errorMessage,
          style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // Отправляем событие повторной инициализации
            context.read<SplashBloc>().add(const SplashRetryInitialization());
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Повторить'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            // Отправляем событие принудительного перехода на логин
            context.read<SplashBloc>().add(const SplashForceGoToLogin());
          },
          child: const Text(
            'Перейти к авторизации',
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }
}
