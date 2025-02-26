import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../helpers/helpers.dart';
import '../../providers/words_notifier_provider.dart';
import '../ui.dart';

class AddWordBottomSheet extends ConsumerStatefulWidget {
  const AddWordBottomSheet({super.key});

  @override
  ConsumerState<AddWordBottomSheet> createState() => _AddWordBottomSheetState();
}

class _AddWordBottomSheetState extends ConsumerState<AddWordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  Future<void> _submitWord() async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final wordsNotifier = ref.read(wordsNotifierProvider.notifier);

    try {
      navigator.pop();
      await wordsNotifier.addWord(
        word: _wordController.text.trim(),
      );
    } catch (e, stackTrace) {
      logger.e(
        'Error adding a word',
        error: e,
        stackTrace: stackTrace,
      );
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        hint: Hint.withMap(
          {'screen': 'add_word_bottom_sheet'},
        ),
      );
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to add word: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: context.spacing.md,
        right: context.spacing.md,
        top: context.spacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + context.spacing.md,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add New Word',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.md),
            TextFormField(
              controller: _wordController,
              decoration: const InputDecoration(
                labelText: 'Word',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitWord(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a word';
                }
                return null;
              },
            ),
            SizedBox(height: context.spacing.md),
            ElevatedButton(
              onPressed: _submitWord,
              child: const Text('Add Word'),
            ),
          ],
        ),
      ),
    );
  }
}
