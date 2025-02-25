import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helpers/helpers.dart';
import '../../providers/words_notifier_provider.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const path = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wordy')),
      body: Padding(
        padding: EdgeInsets.all(context.spacing.md),
        child: const _HomeBody(
          key: ValueKey('Home Body'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => const AddWordBottomSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsNotifierProvider);

    return wordsAsync.when(
      data: (words) => WordsList(words: words),
      loading: () => const WordsList(words: [], isLoading: true),
      error: (error, stackTrace) {
        logger.e(
          'Error with wordsNotifierProvider',
          stackTrace: stackTrace,
          error: error,
        );
        return ErrorView(
          errorMessage:
              'Failed to fetch words.\nCheck your internet connection',
          onRetry: () => ref.invalidate(wordsNotifierProvider),
        );
      },
    );
  }
}
