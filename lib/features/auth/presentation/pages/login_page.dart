import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hims/features/auth/presentation/bloc/auth_cubit.dart';
import '../../../../../../app/auto_router.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _homeNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state == AuthState.authenticated) {
          context.router.replace(const PickHomeRoute());
        }
      },
      child: Scaffold(
        backgroundColor: Colors.blue[300],
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Welcome to HIMS",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                AppTextField(homeNameController: _homeNameController),
                AppTextField(homeNameController: _passwordController),
                const SizedBox(height: 10),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state == AuthState.loading) {
                      return const CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state == AuthState.loading) {
                      return const SizedBox.shrink();
                    }
                    return TextButton(
                      onPressed: () {
                        context.read<AuthCubit>().handleSignIn();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/logos/google-logo.png',
                            height: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Sign in with Google',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Показываем ошибки если есть
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final authCubit = context.read<AuthCubit>();
                    if (authCubit.errorMessage.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          authCubit.errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required TextEditingController homeNameController,
  }) : _homeNameController = homeNameController;

  final TextEditingController _homeNameController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: 300,
        child: TextField(
          controller: _homeNameController,
          decoration: InputDecoration(
            labelText: 'Home Name',
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.blueAccent,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
    );
  }
}
