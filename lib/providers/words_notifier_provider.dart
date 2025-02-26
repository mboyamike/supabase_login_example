import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_login_example/providers/providers.dart';
import 'package:supabase_login_example/repositories/words_repository.dart';

import '../models/models.dart';

part 'words_notifier_provider.g.dart';

@riverpod
class WordsNotifier extends _$WordsNotifier {
  @override
  Stream<List<Word>> build() async* {
    final wordsRepository = ref.watch(wordsRepositoryProvider);
    final userID = await ref.watch(
      authenticationNotifierProvider.selectAsync((user) => user?.id),
    );

    if (userID == null) {
      throw Exception('You need to be signed in to fetch favorite words');
    }

    yield* wordsRepository.getWords(userID: userID).map(
          (words) => words.toList(),
        );
  }

  Future<void> addWord({required String word}) async {
    final user = await ref.read(authenticationNotifierProvider.future);
    final wordsRepository = ref.read(wordsRepositoryProvider);

    if (user == null) {
      throw Exception('Must be signed in to add a word');
    }

    final now = DateTime.now();
    final optimisticWord = Word(
      id: -now.millisecondsSinceEpoch, // Temporary negative ID
      word: word,
      userID: user.id,
    );

    state = AsyncData([...state.value ?? [], optimisticWord]);

    try {
      await wordsRepository.addWord(word: word, userID: user.id);
    } catch (e) {
      // If there's an error, revert the optimistic update
      if (state.hasValue) {
        state = AsyncData(
          state.value!.where((w) => w.id != optimisticWord.id).toList(),
        );
      }
      
      rethrow;
    }
  }

  Future<void> deleteWord({required int id}) async {
    final wordsRepository = ref.read(wordsRepositoryProvider);
    wordsRepository.deleteWord(id: id);
  }
}
