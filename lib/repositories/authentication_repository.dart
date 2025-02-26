import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'authentication_repository.g.dart';

class AuthenticationRepository {
  AuthenticationRepository({required this.supabaseAuth});

  final GoTrueClient supabaseAuth;

  Stream<AuthState> onAuthStateChange() => supabaseAuth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return supabaseAuth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return supabaseAuth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => supabaseAuth.signOut();
}

@riverpod
AuthenticationRepository authenticationRepository(Ref ref) {
  final supabaseAuth = Supabase.instance.client.auth;
  return AuthenticationRepository(supabaseAuth: supabaseAuth);
}
