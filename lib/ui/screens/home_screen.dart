import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_login_example/providers/authentication_notifier_provider.dart';

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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Wordy'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authenticationNotifierProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
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

    ref.listen(
      wordsNotifierProvider,
      (previous, current) {
        if (!(previous is AsyncData && current is AsyncData)) {
          return;
        }

        final previousValue = previous?.value ?? [];
        final currentValue = current.value ?? [];

        if (currentValue.length == previousValue.length + 1) {
          final currentWordCount = currentValue.length;
          final congratulatoryCounts = [5, 12, 17, 21, 25];

          if (congratulatoryCounts.contains(currentWordCount)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('You have $currentWordCount words!'),
              ),
            );
          }
        }
      },
    );

    return switch (wordsAsync) {
      AsyncData(value: final words) => WordsList(words: words),
      AsyncError(:final error, :final stackTrace, isLoading: false) =>
        Builder(builder: (context) {
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
        }),
      _ => const WordsList(words: [], isLoading: true),
    };
  }
}
