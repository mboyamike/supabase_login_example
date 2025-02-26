import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_login_example/providers/authentication_notifier_provider.dart';
import 'package:supabase_login_example/ui/ui.dart';

import 'helpers/helpers.dart';

Future<void> main() async {
  await dotenv.load();
  final projectURL = dotenv.get('PROJECT_URL');
  final apiKey = dotenv.get('API_KEY');
  await Supabase.initialize(url: projectURL, anonKey: apiKey);

  runApp(
    ProviderScope(child: MainApp()),
  );
}

class MainApp extends ConsumerWidget {
  MainApp({super.key});

  final router = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      authenticationNotifierProvider,
      ((_, curr) => logger.t('UserAsync $curr')),
    );

    return MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router.config(),
    );
  }
}
