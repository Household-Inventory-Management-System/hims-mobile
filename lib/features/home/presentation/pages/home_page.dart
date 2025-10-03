import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hims/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/auto_router.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    context.router.replace(const LoginRoute()); // Выход и редирект
  }

  @override
  Widget build(BuildContext context) {
    final homeName = AuthService().currentUser!.home?.name ?? '';

    return Scaffold(
      drawer: Container(
        decoration: BoxDecoration(color: Colors.white),
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(),
              padding: EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Icon(Icons.home_rounded),
                  const SizedBox(width: 4),
                  Text('Home'),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(title: Text(homeName)),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _logout(context),
          child: Text("Выйти"),
        ),
      ),
    );
  }
}
