import 'package:auto_route/auto_route.dart';
import 'package:hims/ui/screens/pick_home_page.dart';
import '../ui/screens/home_page.dart';
import '../ui/screens/login_page.dart';
import '../ui/screens/splash_page.dart';

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
