// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_gpt_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ChatGptModel _$ChatGptModelFromJson(Map<String, dynamic> json) {
  return _ChatGptModel.fromJson(json);
}

/// @nodoc
mixin _$ChatGptModel {
  @JsonKey(name: 'model')
  String get model => throw _privateConstructorUsedError;
  @JsonKey(name: 'choices', fromJson: fetchChoicesFromJson)
  List<dynamic> get choices => throw _privateConstructorUsedError;
  @JsonKey(name: 'usage', fromJson: fetchUsageFromJson)
  int get tokenUsage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatGptModelCopyWith<ChatGptModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatGptModelCopyWith<$Res> {
  factory $ChatGptModelCopyWith(
          ChatGptModel value, $Res Function(ChatGptModel) then) =
      _$ChatGptModelCopyWithImpl<$Res, ChatGptModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'model')
          String model,
      @JsonKey(name: 'choices', fromJson: fetchChoicesFromJson)
          List<dynamic> choices,
      @JsonKey(name: 'usage', fromJson: fetchUsageFromJson)
          int tokenUsage});
}

/// @nodoc
class _$ChatGptModelCopyWithImpl<$Res, $Val extends ChatGptModel>
    implements $ChatGptModelCopyWith<$Res> {
  _$ChatGptModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? model = null,
    Object? choices = null,
    Object? tokenUsage = null,
  }) {
    return _then(_value.copyWith(
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      choices: null == choices
          ? _value.choices
          : choices // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      tokenUsage: null == tokenUsage
          ? _value.tokenUsage
          : tokenUsage // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ChatGptModelCopyWith<$Res>
    implements $ChatGptModelCopyWith<$Res> {
  factory _$$_ChatGptModelCopyWith(
          _$_ChatGptModel value, $Res Function(_$_ChatGptModel) then) =
      __$$_ChatGptModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'model')
          String model,
      @JsonKey(name: 'choices', fromJson: fetchChoicesFromJson)
          List<dynamic> choices,
      @JsonKey(name: 'usage', fromJson: fetchUsageFromJson)
          int tokenUsage});
}

/// @nodoc
class __$$_ChatGptModelCopyWithImpl<$Res>
    extends _$ChatGptModelCopyWithImpl<$Res, _$_ChatGptModel>
    implements _$$_ChatGptModelCopyWith<$Res> {
  __$$_ChatGptModelCopyWithImpl(
      _$_ChatGptModel _value, $Res Function(_$_ChatGptModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? model = null,
    Object? choices = null,
    Object? tokenUsage = null,
  }) {
    return _then(_$_ChatGptModel(
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      choices: null == choices
          ? _value._choices
          : choices // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      tokenUsage: null == tokenUsage
          ? _value.tokenUsage
          : tokenUsage // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable()
class _$_ChatGptModel implements _ChatGptModel {
  _$_ChatGptModel(
      {@JsonKey(name: 'model')
          required this.model,
      @JsonKey(name: 'choices', fromJson: fetchChoicesFromJson)
          required final List<dynamic> choices,
      @JsonKey(name: 'usage', fromJson: fetchUsageFromJson)
          required this.tokenUsage})
      : _choices = choices;

  factory _$_ChatGptModel.fromJson(Map<String, dynamic> json) =>
      _$$_ChatGptModelFromJson(json);

  @override
  @JsonKey(name: 'model')
  final String model;
  final List<dynamic> _choices;
  @override
  @JsonKey(name: 'choices', fromJson: fetchChoicesFromJson)
  List<dynamic> get choices {
    if (_choices is EqualUnmodifiableListView) return _choices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_choices);
  }

  @override
  @JsonKey(name: 'usage', fromJson: fetchUsageFromJson)
  final int tokenUsage;

  @override
  String toString() {
    return 'ChatGptModel(model: $model, choices: $choices, tokenUsage: $tokenUsage)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ChatGptModel &&
            (identical(other.model, model) || other.model == model) &&
            const DeepCollectionEquality().equals(other._choices, _choices) &&
            (identical(other.tokenUsage, tokenUsage) ||
                other.tokenUsage == tokenUsage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, model,
      const DeepCollectionEquality().hash(_choices), tokenUsage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ChatGptModelCopyWith<_$_ChatGptModel> get copyWith =>
      __$$_ChatGptModelCopyWithImpl<_$_ChatGptModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ChatGptModelToJson(
      this,
    );
  }
}

abstract class _ChatGptModel implements ChatGptModel {
  factory _ChatGptModel(
      {@JsonKey(name: 'model')
          required final String model,
      @JsonKey(name: 'choices', fromJson: fetchChoicesFromJson)
          required final List<dynamic> choices,
      @JsonKey(name: 'usage', fromJson: fetchUsageFromJson)
          required final int tokenUsage}) = _$_ChatGptModel;

  factory _ChatGptModel.fromJson(Map<String, dynamic> json) =
      _$_ChatGptModel.fromJson;

  @override
  @JsonKey(name: 'model')
  String get model;
  @override
  @JsonKey(name: 'choices', fromJson: fetchChoicesFromJson)
  List<dynamic> get choices;
  @override
  @JsonKey(name: 'usage', fromJson: fetchUsageFromJson)
  int get tokenUsage;
  @override
  @JsonKey(ignore: true)
  _$$_ChatGptModelCopyWith<_$_ChatGptModel> get copyWith =>
      throw _privateConstructorUsedError;
}
