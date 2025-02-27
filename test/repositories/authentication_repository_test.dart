import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_login_example/repositories/authentication_repository.dart';

class MockGoTrueClient extends Mock implements GoTrueClient {}

class FakeAuthState extends Fake implements AuthState {}

void main() {
  late MockGoTrueClient mockSupabaseAuth;
  late AuthenticationRepository authRepository;

  setUpAll(() {
    registerFallbackValue(FakeAuthState());
  });

  setUp(() {
    mockSupabaseAuth = MockGoTrueClient();
    authRepository = AuthenticationRepository(supabaseAuth: mockSupabaseAuth);
  });

  group('AuthenticationRepository', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    test('signUp returns auth response when successful', () async {
      // Arrange
      final mockUser = User(
        id: 'user-123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );

      final mockSession = Session(
        accessToken: 'access-token',
        tokenType: 'bearer',
        refreshToken: 'refresh-token',
        user: mockUser,
        expiresIn: 3600,
      );

      final expectedResponse = AuthResponse(
        session: mockSession,
        user: mockUser,
      );

      when(() => mockSupabaseAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => expectedResponse);

      // Act
      final result = await authRepository.signUp(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result.user?.id, equals(mockUser.id));
      expect(result.session?.accessToken, equals(mockSession.accessToken));
    });

    test('signIn returns auth response with user and session when successful',
        () async {
      // Arrange
      final mockUser = User(
        id: 'user-123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );

      final mockSession = Session(
        accessToken: 'access-token',
        tokenType: 'bearer',
        refreshToken: 'refresh-token',
        user: mockUser,
        expiresIn: 3600,
      );

      final expectedResponse = AuthResponse(
        session: mockSession,
        user: mockUser,
      );

      when(() => mockSupabaseAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => expectedResponse);

      // Act
      final result = await authRepository.signIn(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result.user?.id, equals(mockUser.id));
      expect(result.session?.accessToken, equals(mockSession.accessToken));
    });

    test('signOut completes successfully', () async {
      // Arrange
      when(() => mockSupabaseAuth.signOut()).thenAnswer((_) async {});

      // Act & Assert
      expect(authRepository.signOut(), completes);
    });

    test('onAuthStateChange emits auth states', () async {
      // Arrange
      final authStates = [
        AuthState(
          AuthChangeEvent.signedIn,
          Session(
            accessToken: 'token',
            tokenType: 'bearer',
            refreshToken: 'refresh',
            user: User(
              id: 'user-123',
              appMetadata: {},
              userMetadata: {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
            expiresIn: 3600,
          ),
        ),
        const AuthState(AuthChangeEvent.signedOut, null),
      ];

      when(() => mockSupabaseAuth.onAuthStateChange)
          .thenAnswer((_) => Stream.fromIterable(authStates));

      // Act & Assert
      expect(
        authRepository.onAuthStateChange(),
        emitsInOrder([
          predicate<AuthState>(
              (state) => state.event == AuthChangeEvent.signedIn),
          predicate<AuthState>(
              (state) => state.event == AuthChangeEvent.signedOut),
        ]),
      );
    });
  });
}
