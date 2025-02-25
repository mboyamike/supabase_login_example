import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_login_example/providers/authentication_notifier_provider.dart';
import 'package:supabase_login_example/ui/router/app_router.gr.dart';

@RoutePage()
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const path = '/';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkForCorrectRoute();
  }

  Future<void> checkForCorrectRoute() async {
    final (user, _) = await (
      ref.read(authenticationNotifierProvider.future),
      // To avoid a jarring switch from splash to next screen  
      Future.delayed(Durations.long2)
    ).wait;
    if (user == null) {
      context.replaceRoute(const SignUpRoute());
    } else {
      context.replaceRoute(const HomeRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: LoadingAnimationWidget.stretchedDots(
          color: colorScheme.onSurface,
          size: 24,
        ),
      ),
    );
  }
}
