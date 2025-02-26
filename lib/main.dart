import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_login_example/helpers/provider_observer.dart';
import 'package:supabase_login_example/providers/authentication_notifier_provider.dart';
import 'package:supabase_login_example/ui/router/app_router.gr.dart';
import 'package:supabase_login_example/ui/screens/sign_up_screen.dart';
import 'package:supabase_login_example/ui/screens/splash_screen.dart';
import 'package:supabase_login_example/ui/ui.dart';

import 'helpers/helpers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  final projectURL = dotenv.get('PROJECT_URL');
  final apiKey = dotenv.get('API_KEY');
  await Supabase.initialize(url: projectURL, anonKey: apiKey);

  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.get('SENTRY_DSN');
      options.tracesSampleRate = 0.2;
      options.profilesSampleRate = 1.0;
    },
    // ignore: missing_provider_scope
    appRunner: () => runApp(
      SentryWidget(
        child: ProviderScope(
          observers: const [
            SentryProviderObserver(),
          ],
          child: MainApp(),
        ),
      ),
    ),
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Sentry.captureException(
      details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    Sentry.captureException(error, stackTrace: stack);
    return true;
  };
}

class MainApp extends ConsumerWidget {
  MainApp({super.key});

  final router = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      authenticationNotifierProvider,
      ((_, current) {
        // This listener acts as a routeguard, ensuring that if the user is not
        // logged in, they are redirected to the splash page
        logger.t('UserAsync $current');

        if (current is! AsyncData) {
          return;
        }

        final user = current.valueOrNull;
        if (user != null) {
          return;
        }

        final currentPath = router.routeData.path;
        final initialAndAuthPaths = [
          SplashScreen.path,
          SignInScreen.path,
          SignUpScreen.path
        ];

        if (!initialAndAuthPaths.contains(currentPath)) {
          router.replaceAll([const SplashRoute()]);
        }
      }),
    );

    return MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router.config(),
    );
  }
}
