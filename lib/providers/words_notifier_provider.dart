import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_login_example/providers/providers.dart';
import 'package:supabase_login_example/repositories/words_repository.dart';

import '../models/models.dart';

part 'words_notifier_provider.g.dart';

@riverpod
class WordsNotifier extends _$WordsNotifier {
  @override
  Stream<List<Word>> build() async* {
    final wordsRepository = await ref.watch(wordsRepositoryProvider.future);
    final user = await ref.watch(authenticationNotifierProvider.future);
    if (user == null) {
      throw Exception('You need to be signed in to fetch favorite words');
    }
    
    yield* wordsRepository.getWords(userID: user.id).map(
          (words) => words.toList(),
        );
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
