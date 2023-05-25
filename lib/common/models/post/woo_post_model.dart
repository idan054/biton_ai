// ignore_for_file: invalid_annotation_target, depend_on_referenced_packages
import 'package:biton_ai/common/models/category/woo_category_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../services/convertors.dart';
import '../prompt/result_model.dart' as click;
import '../prompt/result_model.dart';
import 'package:intl/intl.dart';

part 'woo_post_model.freezed.dart';

part 'woo_post_model.g.dart';

/// Most clean model: [click.ResultModel]

// flutter pub run build_runner build --delete-conflicting-outputs
// @freezed
@Freezed(toJson: true)
class WooPostModel with _$WooPostModel {
  @JsonSerializable(explicitToJson: true, nullable: true) // needed sub classes
  factory WooPostModel({
    int? id, // doesn't have while create
    required int author,
    required List<int> categories,
    required click.ResultCategory category,
    required String title,
    required String content,
    String? subContent,
    @Default(false) bool isDefault,
    @Default(false) bool isSelected,
  }) = _WooPostModel;

  // factory WooPostModel.fromJson(Map<String, dynamic> json) => _$WooPostModelFromJson(json);
  factory WooPostModel.fromJson(Map<String, dynamic> json) {
    var title = json['title']['rendered'];
    var content = json['content']['rendered']
        .toString()
        .replaceAll('<p>', '')
        .replaceAll('</p>', '')
        .trim();
    var mainContent = fetchContentFromJson(content, false);
    var subContent = fetchContentFromJson(content, true);

    var categoriesRaw = json['categories'] as List<dynamic>;
    var categories = categoriesRaw.map((category) => category as int).toList();

    var post = WooPostModel(
      id: json['id'],
      author: json['author'],
      categories: categories,
      category: getCategory(categories),
      title: title,
      content: mainContent!,
      subContent: subContent,
      isSelected: json['meta']['isSelected'] ?? false,
      isDefault: json['meta']['isDefault'], // the TextStore UID
    );
    return post;
  }
}

// dynamic fetchTitleFromJson(Map<String, dynamic> title) => title['rendered'];

// @JsonKey(name: 'content', fromJson: fetchSubContentFromJson) String? subContent,
// dynamic fetchContentFromJson(Map<String, dynamic> content) =>
//     content['rendered'].toString().replaceAll('<p>', '').replaceAll('</p>', '').trim();

ResultCategory getCategory(List<int> catIds) {
  var catId = catIds.first;
  ResultCategory? type;
  if (catId == 28) type = ResultCategory.gResults;
  if (catId == 29) type = ResultCategory.titles;
  if (catId == 30) type = ResultCategory.shortDesc;
  if (catId == 31) type = ResultCategory.longDesc;
  if (catId == 32) type = ResultCategory.tags;
  return type!;
}

String? fetchContentFromJson(String content, bool subContent) {
  var googleDesc = 'googleDesc=';
  if (content.contains(googleDesc)) {
    return subContent
        ? content.split(googleDesc).last.replaceAll(googleDesc, '')
        : content.split(googleDesc).first;
  } else {
    return subContent ? null : content;
  }
}
