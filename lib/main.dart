import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/auto_router.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/splash_screen/presentation/bloc/splash_screen_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => SplashScreenCubit()),
      ],
      child: MaterialApp.router(
        routerConfig: _appRouter.config(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
