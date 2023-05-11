import 'package:freezed_annotation/freezed_annotation.dart';
import '../../services/convertors.dart';
import '../post/woo_post_model.dart' as click;
part 'result_model.freezed.dart';
part 'result_model.g.dart';

enum ResultCategory { titles, googleResults, shortDesc, longDesc }

/// Full docs in [click.WooPostModel]
@freezed
class ResultModel with _$ResultModel {
  const factory ResultModel({
    @Default(ResultCategory.googleResults) ResultCategory? category,
    required String title,
    String? desc,
  }) = _ResultModel;
  factory ResultModel.fromJson(Map<String, dynamic> json)=>_$ResultModelFromJson(json);
}
