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
    @JsonKey(name: 'title', fromJson: fetchTitleFromJson) required String title,
    @JsonKey(name: 'content', fromJson: fetchContentFromJson) required String content,
  }) = _WooPostModel;

  factory WooPostModel.fromJson(Map<String, dynamic> json) =>
      _$WooPostModelFromJson(json);
}

dynamic fetchTitleFromJson(Map<String, dynamic> title) => title['rendered'];

dynamic fetchContentFromJson(Map<String, dynamic> content) =>
    content['rendered'].toString().replaceAll('<p>', '').replaceAll('</p>', '').trim();
