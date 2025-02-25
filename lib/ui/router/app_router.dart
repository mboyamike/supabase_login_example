import 'package:auto_route/auto_route.dart';
import 'package:supabase_login_example/ui/router/app_router.gr.dart';
import 'package:supabase_login_example/ui/screens/sign_in_screen.dart';
import 'package:supabase_login_example/ui/screens/sign_up_screen.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: SignInRoute.page,
          path: SignInScreen.path,
          initial: true,
        ),
        AutoRoute(page: SignUpRoute.page, path: SignUpScreen.path),
      ];
}
