// ignore_for_file: scoped_providers_should_specify_dependencies
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_login_example/repositories/authentication_repository.dart';
import 'package:supabase_login_example/ui/router/app_router.gr.dart';
import 'package:supabase_login_example/ui/ui.dart';

// Mock classes
class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockStackRouter extends Mock implements StackRouter {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUser extends Mock implements User {}

// Mock route information provider for auto_route
class MockRouteInformationProvider extends Mock
    implements RouteInformationProvider {}

void main() {
  late MockAuthenticationRepository mockAuthRepository;
  late MockStackRouter mockRouter;
  late MockUser mockUser;
  late MockAuthResponse mockAuthResponse;

  setUp(() {
    mockAuthRepository = MockAuthenticationRepository();
    mockRouter = MockStackRouter();
    mockUser = MockUser();
    mockAuthResponse = MockAuthResponse();

    // Setup default behavior for the mock router
    when(() => mockRouter.replaceAll(any())).thenAnswer((_) async {});

    // Setup default behavior for the mock auth response
    when(() => mockAuthResponse.user).thenReturn(mockUser);

    // Register the fallback values for any() matchers
    registerFallbackValue(const HomeRoute());
    registerFallbackValue([const HomeRoute()]);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        // Override the authentication repository provider with our mock
        authenticationRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: Builder(
          builder: (context) {
            // Provide the mock router through the context
            return StackRouterScope(
              controller: mockRouter,
              stateHash: 0,
              child: const SignInScreen(),
            );
          },
        ),
      ),
    );
  }

  group('SignInScreen', () {
    testWidgets('should display the sign in form', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Sign In'), findsWidgets);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - tap the sign in button without entering any data
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should show validation error for invalid email',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - enter invalid email and valid password
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsNothing);
    });

    testWidgets('should show validation error for short password',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - enter valid email and short password
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), '12345');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsNothing);
      expect(find.text('Please enter at least 6 letters'), findsOneWidget);
    });

    testWidgets('should call sign in when form is valid',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      when(() => mockAuthRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockAuthResponse);

      // Act - enter valid credentials and submit
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester
          .pump(const Duration(seconds: 1)); // Wait for async operations

      // Assert
      verify(() => mockAuthRepository.signIn(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });

    testWidgets('should navigate to home screen on successful sign in',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      when(() => mockAuthRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockAuthResponse);

      // Act - enter valid credentials and submit
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester
          .pump(const Duration(seconds: 1)); // Wait for async operations

      // Assert
      verify(() => mockRouter.replaceAll([const HomeRoute()])).called(1);
    });
  });
}
