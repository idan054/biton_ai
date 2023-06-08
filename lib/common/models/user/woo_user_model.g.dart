// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'woo_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_WooUserModel _$$_WooUserModelFromJson(Map<String, dynamic> json) =>
    _$_WooUserModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      token: json['token'] as String?,
      isGoogleAuth: json['isGoogleAuth'] as bool? ?? false,
      points: json['points'] as int? ?? 0,
    );

Map<String, dynamic> _$$_WooUserModelToJson(_$_WooUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'token': instance.token,
      'isGoogleAuth': instance.isGoogleAuth,
      'points': instance.points,
    };
