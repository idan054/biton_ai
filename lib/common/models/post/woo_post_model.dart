// ignore_for_file: invalid_annotation_target, depend_on_referenced_packages
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../services/convertors.dart';
import '../prompt/result_model.dart' as click;

part 'woo_post_model.freezed.dart';

part 'woo_post_model.g.dart';

/// Most clean model: [click.ResultModel]

// flutter pub run build_runner build --delete-conflicting-outputs
@freezed
class WooPostModel with _$WooPostModel {
  @JsonSerializable(explicitToJson: true, nullable: true) // needed sub classes
  factory WooPostModel({
    int? id, // doesn't have while create
    required int author,
    required List<int> categories,
    required String title,
    required String content,
    String? subContent,
  }) = _WooPostModel;

  factory WooPostModel.fromJson(Map<String, dynamic> json) {
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
      title: json['title']['rendered'],
      content: mainContent!,
      subContent: subContent,
    );
    // return _$WooPostModelFromJson(json);
    return post;
  }
}

// dynamic fetchTitleFromJson(Map<String, dynamic> title) => title['rendered'];

// @JsonKey(name: 'content', fromJson: fetchSubContentFromJson) String? subContent,
// dynamic fetchContentFromJson(Map<String, dynamic> content) =>
//     content['rendered'].toString().replaceAll('<p>', '').replaceAll('</p>', '').trim();


String? fetchContentFromJson(String content, bool subContent) {
  var googleDesc = ' googleDesc=';
  if (content.contains(googleDesc)) {
    return subContent
        ? content.split(googleDesc).last.replaceAll(googleDesc, '')
        : content.split(googleDesc).first;
  } else {
    return subContent ? null : content;
  }
}
