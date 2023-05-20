import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../post/woo_post_model.dart' as click;
part 'woo_user_model.freezed.dart';
part 'woo_user_model.g.dart';


/// Full docs in [click.WooPostModel]
@freezed
class WooUserModel with _$WooUserModel {
  @JsonSerializable(explicitToJson: true)
  const factory WooUserModel({
    int? id,
    String? name,
    String? email,
    String? token, // JWT
  }) = _WooUserModel;

  factory WooUserModel.fromJson(Map<String, dynamic> json) =>
      _$WooUserModelFromJson(json);
}
