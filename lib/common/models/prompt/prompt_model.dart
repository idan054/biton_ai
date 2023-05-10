import 'package:freezed_annotation/freezed_annotation.dart';
import '../post/woo_post_model.dart' as click;
part 'prompt_model.freezed.dart';

/// Full docs in [click.WooPostModel]
@freezed
class PromptModel with _$PromptModel {
  const factory PromptModel({
    required String name,
    required String content,
    required int authorUid,
    required int categoryId,
    String? categoryName,
  }) = _PromptModel;
}
