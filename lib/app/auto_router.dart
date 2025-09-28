import 'package:auto_route/auto_route.dart';
import 'package:hims/features/pick-create-home/presentation/pages/pick_home_page.dart';
import 'package:hims/features/splash_screen/presentation/screen/splash_screen.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/auth/presentation/pages/login_page.dart';

part 'auto_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter  {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: PickHomeRoute.page),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: HomeRoute.page),
      ];
}
