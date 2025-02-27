import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_login_example/models/models.dart';
import 'package:supabase_login_example/repositories/words_repository.dart';

void main() {
  late WordsRepository repository;
  late SupabaseClient mockClient;
  late MockSupabaseHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockSupabaseHttpClient();
    mockClient = SupabaseClient(
      'https://mock.supabase.co',
      'fakeAnonKey',
      httpClient: mockHttpClient,
    );
    repository = WordsRepository(supabaseClient: mockClient);
  });

  tearDown(() {
    mockHttpClient.reset();
  });

  group('WordsRepository', () {
    const testUserId = 'test-user-id';
    const testWord = 'test-word';
    const testWordId = 1;

    group('getWords', () {
      test('returns stream of words for user', () async {
        // Insert mock data that will be returned by the stream
        await mockClient.from('words').insert([
          {'id': 1, 'word': 'test1', 'user_id': testUserId, 'is_active': true},
          {'id': 2, 'word': 'test2', 'user_id': testUserId, 'is_active': true},
        ]);

        final stream = repository.getWords(userID: testUserId);

        // Verify the stream emits the expected words
        final emittedWords = await stream.first;
        expect(emittedWords.length, 2);
        expect(
          emittedWords,
          containsAll([
            isA<Word>()
                .having((w) => w.id, 'id', 1)
                .having((w) => w.word, 'word', 'test1'),
            isA<Word>()
                .having((w) => w.id, 'id', 2)
                .having((w) => w.word, 'word', 'test2'),
          ]),
        );
      });
    });

    group('addWord', () {
      test('successfully adds word and returns response', () async {
        await repository.addWord(
          word: testWord,
          userID: testUserId,
        );

        // Verify the word was added to the mock database
        final words = await mockClient.from('words').select();
        expect(words.length, 1);
        expect(words.first['word'], testWord);
        expect(words.first['user_id'], testUserId);
      });

      // Note: With mock_supabase_http_client, we can't easily simulate failures
      // You might need to use a different approach for testing error cases
    });

    group('deleteWord', () {
      test('successfully marks word as deleted', () async {
        // Insert a word to be deleted
        await mockClient.from('words').insert({
          'id': testWordId,
          'word': testWord,
          'user_id': testUserId,
          'is_active': true,
        });

        await repository.deleteWord(id: testWordId);

        // Verify the word was marked as deleted
        final words =
            await mockClient.from('words').select().eq('id', testWordId);

        expect(words.length, 1);
        expect(words.first['is_active'], false);
        expect(words.first['deleted_at'], isNotNull);
      });

      // Note: With mock_supabase_http_client, we can't easily simulate failures
      // You might need to use a different approach for testing error cases
    });
  });
}
