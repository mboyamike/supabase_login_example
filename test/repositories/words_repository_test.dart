import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_login_example/models/models.dart';
import 'package:supabase_login_example/repositories/words_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {
  PostgrestFilterBuilder<T> eq<T>(String column, dynamic value) {
    return MockPostgrestFilterBuilder<T>();
  }
}

class MockPostgrestFilterBuilder<T> extends Mock
    implements PostgrestFilterBuilder<T> {
  Future<PostgrestResponse<T>> execute() async {
    return PostgrestResponse<T>(
      data: [] as T,
      count: 0,
    );
  }
}

class FakePostgrestResponse<T> extends PostgrestResponse<T> {
  FakePostgrestResponse({required super.data, required super.count});
}

class MockSupabaseStreamBuilder extends Mock
    implements SupabaseStreamFilterBuilder {
  @override
  SupabaseStreamBuilder eq(String column, Object value) {
    return this;
  }

  Stream<List<Map<String, dynamic>>> get stream => Stream.value([
        {'id': 1, 'word': 'test1', 'user_id': 'test-user-id'},
        {'id': 2, 'word': 'test2', 'user_id': 'test-user-id'},
      ]);
}

void main() {
  late WordsRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockSupabaseStreamBuilder mockStreamBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockStreamBuilder = MockSupabaseStreamBuilder();
    repository = WordsRepository(supabaseClient: mockClient);

    registerFallbackValue({});
  });

  group('WordsRepository', () {
    const testUserId = 'test-user-id';
    const testWord = 'test-word';
    const testWordId = 1;

    group('getWords', () {
      test('returns stream of words for user', () {
        when(() => mockClient.from('words')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.stream(primaryKey: ['id']))
            .thenReturn(mockStreamBuilder);

        final stream = repository.getWords(userID: testUserId);

        expect(
          stream,
          emits(isA<Iterable<Word>>()
              .having((words) => words.length, 'length', 2)),
        );
      });
    });

    group('addWord', () {
      test('successfully adds word and returns response', () async {
        final mockFilterBuilder =
            MockPostgrestFilterBuilder<Map<String, dynamic>>();
        final expectedResponse = FakePostgrestResponse<Map<String, dynamic>>(
          data: {'id': 3, 'word': testWord, 'user_id': testUserId},
          count: 1,
        );

        when(() => mockClient.from('words')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.insert(any()))
            .thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.execute())
            .thenAnswer((_) async => expectedResponse);

        await repository.addWord(
          word: testWord,
          userID: testUserId,
        );

        verify(() => mockClient.from('words')).called(1);
        verify(() => mockQueryBuilder.insert({
              'word': testWord,
              'user_id': testUserId,
            })).called(1);
        verify(() => mockFilterBuilder.execute()).called(1);
      });

      test('throws exception when insert fails', () async {
        final mockFilterBuilder =
            MockPostgrestFilterBuilder<Map<String, dynamic>>();
        when(() => mockClient.from('words')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.insert(any()))
            .thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.execute())
            .thenThrow(Exception('Insert failed'));

        expect(
          () => repository.addWord(word: testWord, userID: testUserId),
          throwsException,
        );
      });
    });

    group('deleteWord', () {
      test('successfully marks word as deleted', () async {
        final mockFilterBuilder =
            MockPostgrestFilterBuilder<Map<String, dynamic>>();
        final expectedResponse = FakePostgrestResponse<Map<String, dynamic>>(
          data: {
            'id': testWordId,
            'word': testWord,
            'user_id': testUserId,
            'is_active': false,
            'deleted_at': DateTime.now().toIso8601String(),
          },
          count: 1,
        );

        when(() => mockClient.from('words')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.update(any()))
            .thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.eq('id', testWordId))
            .thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.execute())
            .thenAnswer((_) async => expectedResponse);

        await repository.deleteWord(id: testWordId);

        verify(() => mockClient.from('words')).called(1);
        verify(() => mockQueryBuilder.update(any(
                that: predicate((Map<String, dynamic> data) =>
                    data['is_active'] == false && data['deleted_at'] != null))))
            .called(1);
        verify(() => mockFilterBuilder.eq('id', testWordId)).called(1);
        verify(() => mockFilterBuilder.execute()).called(1);
      });

      test('throws exception when delete fails', () async {
        final mockFilterBuilder =
            MockPostgrestFilterBuilder<Map<String, dynamic>>();
        when(() => mockClient.from('words')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.update(any()))
            .thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.eq('id', testWordId))
            .thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.execute())
            .thenThrow(Exception('Delete failed'));

        expect(
          () => repository.deleteWord(id: testWordId),
          throwsException,
        );
      });
    });
  });
}
