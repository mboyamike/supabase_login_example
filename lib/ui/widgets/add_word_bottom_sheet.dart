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
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  Future<void> _submitWord() async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(wordsNotifierProvider.notifier).addWord(
            word: _wordController.text.trim(),
          );
      if (mounted) {
        navigator.pop();
      }
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
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
            if (_errorMessage != null) ...[
              SizedBox(height: context.spacing.xs),
              Text(
                _errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: context.spacing.md),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitWord,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add Word'),
            ),
          ],
        ),
      ),
    );
  }
}
