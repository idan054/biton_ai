// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'woo_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$WooUserModel {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get token => throw _privateConstructorUsedError; // JWT
  int get points => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WooUserModelCopyWith<WooUserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WooUserModelCopyWith<$Res> {
  factory $WooUserModelCopyWith(
          WooUserModel value, $Res Function(WooUserModel) then) =
      _$WooUserModelCopyWithImpl<$Res, WooUserModel>;
  @useResult
  $Res call({int? id, String? name, String? phone, String? token, int points});
}

/// @nodoc
class _$WooUserModelCopyWithImpl<$Res, $Val extends WooUserModel>
    implements $WooUserModelCopyWith<$Res> {
  _$WooUserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? phone = freezed,
    Object? token = freezed,
    Object? points = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_WooUserModelCopyWith<$Res>
    implements $WooUserModelCopyWith<$Res> {
  factory _$$_WooUserModelCopyWith(
          _$_WooUserModel value, $Res Function(_$_WooUserModel) then) =
      __$$_WooUserModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String? name, String? phone, String? token, int points});
}

/// @nodoc
class __$$_WooUserModelCopyWithImpl<$Res>
    extends _$WooUserModelCopyWithImpl<$Res, _$_WooUserModel>
    implements _$$_WooUserModelCopyWith<$Res> {
  __$$_WooUserModelCopyWithImpl(
      _$_WooUserModel _value, $Res Function(_$_WooUserModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? phone = freezed,
    Object? token = freezed,
    Object? points = null,
  }) {
    return _then(_$_WooUserModel(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_WooUserModel implements _WooUserModel {
  const _$_WooUserModel(
      {this.id, this.name, this.phone, this.token, this.points = 0});

  @override
  final int? id;
  @override
  final String? name;
  @override
  final String? phone;
  @override
  final String? token;
// JWT
  @override
  @JsonKey()
  final int points;

  @override
  String toString() {
    return 'WooUserModel(id: $id, name: $name, phone: $phone, token: $token, points: $points)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_WooUserModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.points, points) || other.points == points));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, phone, token, points);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_WooUserModelCopyWith<_$_WooUserModel> get copyWith =>
      __$$_WooUserModelCopyWithImpl<_$_WooUserModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_WooUserModelToJson(
      this,
    );
  }
}

abstract class _WooUserModel implements WooUserModel {
  const factory _WooUserModel(
      {final int? id,
      final String? name,
      final String? phone,
      final String? token,
      final int points}) = _$_WooUserModel;

  @override
  int? get id;
  @override
  String? get name;
  @override
  String? get phone;
  @override
  String? get token;
  @override // JWT
  int get points;
  @override
  @JsonKey(ignore: true)
  _$$_WooUserModelCopyWith<_$_WooUserModel> get copyWith =>
      throw _privateConstructorUsedError;
}
