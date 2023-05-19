import 'package:biton_ai/common/models/prompt/result_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../post/woo_post_model.dart' as click;
part 'woo_category_model.freezed.dart';
// part 'woo_category_model.g.dart';

/// Full docs in [click.WooPostModel]
@freezed
class WooCategoryModel with _$WooCategoryModel {
  const factory WooCategoryModel({
    required ResultCategory type,
    required int id,
    required String name,
    required String slug,
  }) = _WooCategoryModel;

  // factory WooCategoryModel.fromJson(Map<String, dynamic> json) => _$WooCategoryModelFromJson(json);
  factory WooCategoryModel.fromJson(Map<String, dynamic> json) {
    var category = WooCategoryModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      type: click.getCategory([json['id']]),
    );
    return category;
  }
}
