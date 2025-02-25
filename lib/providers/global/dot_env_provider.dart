import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dot_env_provider.g.dart';

@riverpod
Future<Map<String, dynamic>> dotEnv(Ref ref) async {
  ref.keepAlive();
  await dotenv.load();
  return dotenv.env;
}
