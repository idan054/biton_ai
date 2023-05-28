import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../post/woo_post_model.dart' as click;
part 'woo_user_model.freezed.dart';
part 'woo_user_model.g.dart';


/// Full docs in [click.WooPostModel]
@Freezed(toJson: true)
class WooUserModel with _$WooUserModel {
  @JsonSerializable(explicitToJson: true)
  const factory WooUserModel({
    int? id,
    String? name,
    String? phone,
    String? token, // JWT
    @Default(0) int points,
  }) = _WooUserModel;

  // factory WooUserModel.fromJson(Map<String, dynamic> json) => _$WooUserModelFromJson(json);
  factory WooUserModel.fromJson(Map<String, dynamic> json) {
    final points = int.parse(json['description'].toString());
    final user = WooUserModel(
      id: json['id'],
      name: json['name'],
      phone: json['acf']['phone'],
      token: null,
      points: points,
    );
    return user;
  }
}
