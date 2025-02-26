// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'word.freezed.dart';
part 'word.g.dart';

@freezed
class Word with _$Word {
  const factory Word({
    required int id,
    required String word,
    // I would ideally set the casing in the build.yaml if certain that all
    // fields would use snake_case
    @JsonKey(name: 'user_id') 
    required String userID,
  }) = _Word;

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
}
