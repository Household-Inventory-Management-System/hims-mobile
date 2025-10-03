import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hims/core/themes/app_theme.dart';
import 'app/auto_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/splash_screen/presentation/bloc/splash_screen_bloc.dart';
import 'features/pick-create-home/presentation/bloc/pick_home_bloc.dart';
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
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => SplashBloc()),
        BlocProvider(create: (_) => PickHomeBloc()),
      ],
      child: MaterialApp.router(
        theme: lightTheme,
        routerConfig: _appRouter.config(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
