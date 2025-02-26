import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../helpers/helpers.dart';
import '../../providers/providers.dart';
import '../router/app_router.gr.dart';
import '../theme/theme.dart';

@RoutePage()
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  static const path = '/auth/sign_up';

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sign Up',
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.xl),
              const Expanded(child: SignUpForm()),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpForm extends ConsumerStatefulWidget {
  const SignUpForm({super.key});

  @override
  ConsumerState<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            SizedBox(height: spacing.md),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return Validators.passwordValidator(value);
              },
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
                  final scaffoldMessengerState = ScaffoldMessenger.of(context);
                  final router = context.router;

                  try {
                    final response = await ref
                        .read(authenticationNotifierProvider.notifier)
                        .signUp(
                          email: email,
                          password: password,
                        );
                    if (response.user != null && mounted) {
                      router.replace(const HomeRoute());
                    }
                  } catch (e, stackTrace) {
                    logger.e(
                      'Error signing up',
                      error: e,
                      stackTrace: stackTrace,
                    );

                    
                    Sentry.captureException(
                      e,
                      stackTrace: stackTrace,
                      hint: Hint.withMap({
                        'message': 'Error during user sign up',
                      }),
                    );

                    String errorMessage = 'Failed to sign up.';
                    if (e is SocketException) {
                      errorMessage =
                          '$errorMessage Check your internet connection and try again';
                    }
                    scaffoldMessengerState.showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
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
                    const Text('Sign Up'),
                    if (_isLoading) ...[
                      SizedBox(width: context.spacing.md),
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
                  'Already have an account?',
                  style: textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () => context.router.replace(const SignInRoute()),
                  child: Text(
                    'Sign In',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
