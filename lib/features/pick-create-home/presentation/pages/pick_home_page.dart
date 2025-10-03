import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hims/app/auto_router.dart';
import 'package:hims/core/models/home_model.dart';
import '../bloc/pick_home_bloc.dart';

@RoutePage()
class PickHomePage extends StatefulWidget {
  const PickHomePage({super.key});

  @override
  State<PickHomePage> createState() => _PickHomePageState();
}

class _PickHomePageState extends State<PickHomePage> {
  @override
  void initState() {
    super.initState();
    // Загружаем список доступных домов
    context.read<PickHomeBloc>().add(const PickHomeLoadHomes());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PickHomeBloc, PickHomeState>(
      listener: (context, state) {
        // Навигация в зависимости от состояния
        if (state is PickHomeNavigateToHome) {
          context.router.replace(const HomeRoute());
        } else if (state is PickHomeNavigateToLogin) {
          context.router.replace(const LoginRoute());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Выберите или создайте дом'),
          actions: [
            TextButton(
              onPressed: () {
                // Отправляем событие выхода из аккаунта
                context.read<PickHomeBloc>().add(const PickHomeSignOut());
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.exit_to_app_rounded, color: Colors.black),
                  SizedBox(width: 4),
                  Text(
                    'Выйти',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: BlocBuilder<PickHomeBloc, PickHomeState>(
          builder: (context, state) {
            if (state is PickHomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PickHomeLoaded) {
              return _buildHomesList(context, state.homes);
            } else if (state is PickHomeError) {
              return _buildErrorWidget(context, state.message);
            } else {
              return const Center(child: Text('Инициализация...'));
            }
          },
        ),
      ),
    );
  }

  /// Виджет списка домов
  Widget _buildHomesList(BuildContext context, List<Home> homes) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(200),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Выберите дом для управления',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Список доступных домов
            if (homes.isNotEmpty) ...[
              ...homes.map((home) => _buildHomeCard(context, home)),
            ] else ...[
              const Text(
                'У вас пока нет домов. Создайте новый дом, чтобы начать.',
                style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 24),

            // Кнопка создания нового дома
            _buildCreateHomeButton(context),
          ],
        ),
      ),
    );
  }

  /// Карточка дома
  Widget _buildHomeCard(BuildContext context, Home home) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          // Отправляем событие выбора дома
          context.read<PickHomeBloc>().add(
            PickHomeSelectHome(home: home),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[100],
          foregroundColor: Colors.blueGrey[800],
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.home, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    home.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Кнопка создания нового дома
  Widget _buildCreateHomeButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        _showCreateHomeDialog(context);
      },
      icon: const Icon(Icons.add_home),
      label: const Text('Создать новый дом'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Colors.blueAccent),
      ),
    );
  }

  /// Диалог создания нового дома
  void _showCreateHomeDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Создать новый дом'),
            content: TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Название дома',
                hintText: 'Например: Моя квартира',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () {
                  final homeName = textController.text.trim();
                  if (homeName.isNotEmpty) {
                    // Отправляем событие создания дома
                    context.read<PickHomeBloc>().add(
                      PickHomeCreateHome(homeName: homeName),
                    );
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text('Создать'),
              ),
            ],
          ),
    );
  }

  /// Виджет ошибки
  Widget _buildErrorWidget(BuildContext context, String errorMessage) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Произошла ошибка',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 14, color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Повторная загрузка домов
                context.read<PickHomeBloc>().add(const PickHomeLoadHomes());
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
