import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_login_example/repositories/authentication_repository.dart';

part 'authentication_notifier_provider.g.dart';

@riverpod
class AuthenticationNotifier extends _$AuthenticationNotifier {
  @override
  Stream<User?> build() {
    final authenticationRepository =
        ref.watch(authenticationRepositoryProvider);
    final userStream = authenticationRepository
        .onAuthStateChange()
        .map((state) => state.session?.user);
    return userStream;
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    final authenticationRepository = ref.read(authenticationRepositoryProvider);
    return authenticationRepository.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    final authenticationRepository = ref.read(authenticationRepositoryProvider);
    return authenticationRepository.signIn(email: email, password: password);
  }

  Future<void> signOut() {
    final authenticationRepository = ref.read(authenticationRepositoryProvider);
    return authenticationRepository.signOut();
  }
}
