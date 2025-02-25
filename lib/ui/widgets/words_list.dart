import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../gen/assets.gen.dart';
import '../../models/models.dart';
import '../theme/theme.dart';
import 'add_word_bottom_sheet.dart';

class WordsList extends StatefulWidget {
  const WordsList({
    super.key,
    required this.words,
    this.isLoading = false,
  });

  final List<Word> words;
  final bool isLoading;

  @override
  State<WordsList> createState() => _WordsListState();
}

class _WordsListState extends State<WordsList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Word> _currentWords = [];

  @override
  void initState() {
    super.initState();
    _currentWords = List.from(widget.words);
  }

  @override
  void didUpdateWidget(WordsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.isLoading && !oldWidget.isLoading) {
      _updateList(oldWidget.words);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      // If we were loading and now we're not, initialize the list
      _currentWords = List.from(widget.words);
    }
  }

  void _updateList(List<Word> oldWords) {
    // remove deleted words
    for (int i = oldWords.length - 1; i >= 0; i--) {
      final word = oldWords[i];
      if (!widget.words.contains(word)) {
        final removedIndex = _currentWords.indexOf(word);
        if (removedIndex != -1) {
          final removedItem = _currentWords.removeAt(removedIndex);
          _listKey.currentState?.removeItem(
            removedIndex,
            (context, animation) =>
                WordListItem(word: removedItem, animation: animation),
            duration: Durations.medium2,
          );
        }
      }
    }

    // Handle additions
    for (int i = 0; i < widget.words.length; i++) {
      final word = widget.words[i];
      if (!_currentWords.contains(word)) {
        _currentWords.add(word);
        _listKey.currentState?.insertItem(
          _currentWords.length - 1,
          duration: Durations.medium2,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Skeletonizer(
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return const ListTile(title: Text('Word'));
          },
        ),
      );
    }

    if (_currentWords.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(context.spacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(Assets.undrawVoidWez2),
            SizedBox(height: context.spacing.sm),
            const Text('Looks like you do not have any favorite words yet'),
            SizedBox(height: context.spacing.lg),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => const AddWordBottomSheet(),
                );
              },
              child: const Text('Add words'),
            ),
          ],
        ),
      );
    }

    return AnimatedList(
      key: _listKey,
      initialItemCount: _currentWords.length,
      itemBuilder: (context, index, animation) {
        return WordListItem(word: _currentWords[index], animation: animation);
      },
    );
  }
}

class WordListItem extends StatelessWidget {
  const WordListItem({
    super.key,
    required this.word,
    required this.animation,
  });

  final Word word;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: ListTile(
          title: Text(word.word),
        ),
      ),
    );
  }
}
