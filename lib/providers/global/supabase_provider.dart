import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_login_example/providers/global/dot_env_provider.dart';

part 'supabase_provider.g.dart';

@riverpod
Future<Supabase> supabase(Ref ref) async {
  ref.keepAlive();
  
  final env = await ref.watch(dotEnvProvider.future);
  return Supabase.initialize(
    url: env['PROJECT_URL'],
    anonKey: env['API_KEY'],
  );
}
