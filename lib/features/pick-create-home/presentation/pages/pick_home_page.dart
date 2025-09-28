import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hims/app/auto_router.dart';

@RoutePage()
class PickHomePage extends StatelessWidget {
  const PickHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Выбор"),
      ),
      body: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 148, 145, 145),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16 ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the first screen
                        context.router.replace(const HomeRoute()); // Перенаправление на Home

                  },
                  child: const Text('house 1'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the second screen
                    Navigator.pushNamed(context, '/second');
                  },
                  child: const Text('house 2'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}