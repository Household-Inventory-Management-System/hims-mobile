import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_cubit.dart';
import '../../app/auto_router.dart';

@RoutePage() // Аннотация для AutoRoute
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state == AuthState.authenticated) {
          context.router.replace(const HomeRoute());
        } else if (state == AuthState.unauthenticated) {
          context.router.replace(const LoginRoute());
        }
      },
      child: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
