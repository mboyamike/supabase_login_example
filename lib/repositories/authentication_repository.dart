import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_login_example/providers/providers.dart';

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
Future<AuthenticationRepository> authenticationRepository(Ref ref) async {
  final supabase = await ref.watch(supabaseProvider.future);
  return AuthenticationRepository(supabaseAuth: supabase.client.auth);
}
