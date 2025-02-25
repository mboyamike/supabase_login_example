import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_login_example/providers/providers.dart';
import 'package:supabase_login_example/repositories/words_repository.dart';

import '../models/models.dart';

part 'words_notifier_provider.g.dart';

@riverpod
class WordsNotifier extends _$WordsNotifier {
  @override
  Stream<Iterable<Word>> build() async* {
    final wordsRepository = await ref.watch(wordsRepositoryProvider.future);
    yield* wordsRepository.getWords();
  }

  Future<void> addWord({required String word}) async {
    final user = await ref.read(authenticationNotifierProvider.future);
    final wordsRepository = await ref.read(wordsRepositoryProvider.future);

    if (user == null) {
      throw Exception('Must be signed in to add a word');
    }

    return wordsRepository.addWord(word: word, userID: user.id);
  }

  Future<void> deleteWord({required int id}) async {
    final wordsRepository = await ref.read(wordsRepositoryProvider.future);
    wordsRepository.deleteWord(id: id);
  }
}
