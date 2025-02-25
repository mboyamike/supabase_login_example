import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_login_example/providers/providers.dart';

import '../models/models.dart';

part 'words_repository.g.dart';

class WordsRepository {
  WordsRepository({required this.supabaseClient});

  final SupabaseClient supabaseClient;

  Stream<Iterable<Word>> getWords({required String userID}) {
    return supabaseClient
        .from('words')
        .stream(primaryKey: ['id'])
        .eq('user_id', userID)
        .map(
          (wordsJson) => wordsJson.map(Word.fromJson),
        );
  }

  Future<void> addWord({
    required String word,
    required String userID,
  }) async {
    await supabaseClient.from('words').insert({
      'word': word,
      'user_id': userID,
    });
  }

  Future<void> deleteWord({required int id}) async {
    await supabaseClient.from('words').update({
      'is_active': false,
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }
}

@riverpod
Future<WordsRepository> wordsRepository(Ref ref) async {
  final supabase = await ref.watch(supabaseProvider.future);
  return WordsRepository(supabaseClient: supabase.client);
}
