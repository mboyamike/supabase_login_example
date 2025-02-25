import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helpers/helpers.dart';
import '../../providers/providers.dart';
import '../router/app_router.gr.dart';
import '../theme/theme.dart';

@RoutePage()
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  static const path = '/auth/sign_in';

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sign In',
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.xl),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  validator: Validators.emailValidator,
                ),
                SizedBox(height: spacing.md),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  validator: Validators.passwordValidator,
                ),
                SizedBox(height: spacing.lg),
                ElevatedButton(
                  onPressed: () async {
                    if (_isLoading) {
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });

                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      final scaffoldMessengerState =
                          ScaffoldMessenger.of(context);
                      try {
                        await ref
                            .read(authenticationNotifierProvider.notifier)
                            .signIn(
                              email: email,
                              password: password,
                            );
                      } catch (e, stackTrace) {
                        logger.e(
                          'Error signing in',
                          error: e,
                          stackTrace: stackTrace,
                        );
                        // Show error to user
                        scaffoldMessengerState.showSnackBar(
                          const SnackBar(
                            content: Text('Failed to sign in. Try again later'),
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: spacing.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sign In'),
                        if (_isLoading) ...[
                          SizedBox(width: spacing.md),
                          SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: spacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        context.router.replace(const SignUpRoute());
                      },
                      child: Text(
                        'Sign Up',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
