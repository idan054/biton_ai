// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'woo_category_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$WooCategoryModel {
  ResultCategory get type => throw _privateConstructorUsedError;
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WooCategoryModelCopyWith<WooCategoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WooCategoryModelCopyWith<$Res> {
  factory $WooCategoryModelCopyWith(
          WooCategoryModel value, $Res Function(WooCategoryModel) then) =
      _$WooCategoryModelCopyWithImpl<$Res, WooCategoryModel>;
  @useResult
  $Res call({ResultCategory type, int id, String name, String slug});
}

/// @nodoc
class _$WooCategoryModelCopyWithImpl<$Res, $Val extends WooCategoryModel>
    implements $WooCategoryModelCopyWith<$Res> {
  _$WooCategoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? id = null,
    Object? name = null,
    Object? slug = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ResultCategory,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_WooCategoryModelCopyWith<$Res>
    implements $WooCategoryModelCopyWith<$Res> {
  factory _$$_WooCategoryModelCopyWith(
          _$_WooCategoryModel value, $Res Function(_$_WooCategoryModel) then) =
      __$$_WooCategoryModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ResultCategory type, int id, String name, String slug});
}

/// @nodoc
class __$$_WooCategoryModelCopyWithImpl<$Res>
    extends _$WooCategoryModelCopyWithImpl<$Res, _$_WooCategoryModel>
    implements _$$_WooCategoryModelCopyWith<$Res> {
  __$$_WooCategoryModelCopyWithImpl(
      _$_WooCategoryModel _value, $Res Function(_$_WooCategoryModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? id = null,
    Object? name = null,
    Object? slug = null,
  }) {
    return _then(_$_WooCategoryModel(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ResultCategory,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_WooCategoryModel implements _WooCategoryModel {
  const _$_WooCategoryModel(
      {required this.type,
      required this.id,
      required this.name,
      required this.slug});

  @override
  final ResultCategory type;
  @override
  final int id;
  @override
  final String name;
  @override
  final String slug;

  @override
  String toString() {
    return 'WooCategoryModel(type: $type, id: $id, name: $name, slug: $slug)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_WooCategoryModel &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug));
  }

  @override
  int get hashCode => Object.hash(runtimeType, type, id, name, slug);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_WooCategoryModelCopyWith<_$_WooCategoryModel> get copyWith =>
      __$$_WooCategoryModelCopyWithImpl<_$_WooCategoryModel>(this, _$identity);
}

abstract class _WooCategoryModel implements WooCategoryModel {
  const factory _WooCategoryModel(
      {required final ResultCategory type,
      required final int id,
      required final String name,
      required final String slug}) = _$_WooCategoryModel;

  @override
  ResultCategory get type;
  @override
  int get id;
  @override
  String get name;
  @override
  String get slug;
  @override
  @JsonKey(ignore: true)
  _$$_WooCategoryModelCopyWith<_$_WooCategoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}
