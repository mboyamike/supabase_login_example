import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_login_example/providers/authentication_notifier_provider.dart';
import 'package:supabase_login_example/ui/ui.dart';

import 'helpers/helpers.dart';

void main() {
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
