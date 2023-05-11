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

ChatGPTModel _$ChatGPTModelFromJson(Map<String, dynamic> json) {
  return _ChatGPTModel.fromJson(json);
}

/// @nodoc
mixin _$ChatGPTModel {
  @JsonKey(name: 'choices', fromJson: fetchChoicesFromJson)
  List<dynamic> get choices => throw _privateConstructorUsedError;
  @JsonKey(name: 'usage', fromJson: fetchUsageFromJson)
  int get tokenUsage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatGPTModelCopyWith<ChatGPTModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatGPTModelCopyWith<$Res> {
  factory $ChatGPTModelCopyWith(
          ChatGPTModel value, $Res Function(ChatGPTModel) then) =
      _$ChatGPTModelCopyWithImpl<$Res, ChatGPTModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'choices', fromJson: fetchChoicesFromJson)
          List<dynamic> choices,
      @JsonKey(name: 'usage', fromJson: fetchUsageFromJson)
          int tokenUsage});
}

/// @nodoc
class _$ChatGPTModelCopyWithImpl<$Res, $Val extends ChatGPTModel>
    implements $ChatGPTModelCopyWith<$Res> {
  _$ChatGPTModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? choices = null,
    Object? tokenUsage = null,
  }) {
    return _then(_value.copyWith(
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
abstract class _$$_ChatGPTModelCopyWith<$Res>
    implements $ChatGPTModelCopyWith<$Res> {
  factory _$$_ChatGPTModelCopyWith(
          _$_ChatGPTModel value, $Res Function(_$_ChatGPTModel) then) =
      __$$_ChatGPTModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'choices', fromJson: fetchChoicesFromJson)
          List<dynamic> choices,
      @JsonKey(name: 'usage', fromJson: fetchUsageFromJson)
          int tokenUsage});
}

/// @nodoc
class __$$_ChatGPTModelCopyWithImpl<$Res>
    extends _$ChatGPTModelCopyWithImpl<$Res, _$_ChatGPTModel>
    implements _$$_ChatGPTModelCopyWith<$Res> {
  __$$_ChatGPTModelCopyWithImpl(
      _$_ChatGPTModel _value, $Res Function(_$_ChatGPTModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? choices = null,
    Object? tokenUsage = null,
  }) {
    return _then(_$_ChatGPTModel(
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
class _$_ChatGPTModel implements _ChatGPTModel {
  _$_ChatGPTModel(
      {@JsonKey(name: 'choices', fromJson: fetchChoicesFromJson)
          required final List<dynamic> choices,
      @JsonKey(name: 'usage', fromJson: fetchUsageFromJson)
          required this.tokenUsage})
      : _choices = choices;

  factory _$_ChatGPTModel.fromJson(Map<String, dynamic> json) =>
      _$$_ChatGPTModelFromJson(json);

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
    return 'ChatGPTModel(choices: $choices, tokenUsage: $tokenUsage)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ChatGPTModel &&
            const DeepCollectionEquality().equals(other._choices, _choices) &&
            (identical(other.tokenUsage, tokenUsage) ||
                other.tokenUsage == tokenUsage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_choices), tokenUsage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ChatGPTModelCopyWith<_$_ChatGPTModel> get copyWith =>
      __$$_ChatGPTModelCopyWithImpl<_$_ChatGPTModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ChatGPTModelToJson(
      this,
    );
  }
}

abstract class _ChatGPTModel implements ChatGPTModel {
  factory _ChatGPTModel(
      {@JsonKey(name: 'choices', fromJson: fetchChoicesFromJson)
          required final List<dynamic> choices,
      @JsonKey(name: 'usage', fromJson: fetchUsageFromJson)
          required final int tokenUsage}) = _$_ChatGPTModel;

  factory _ChatGPTModel.fromJson(Map<String, dynamic> json) =
      _$_ChatGPTModel.fromJson;

  @override
  @JsonKey(name: 'choices', fromJson: fetchChoicesFromJson)
  List<dynamic> get choices;
  @override
  @JsonKey(name: 'usage', fromJson: fetchUsageFromJson)
  int get tokenUsage;
  @override
  @JsonKey(ignore: true)
  _$$_ChatGPTModelCopyWith<_$_ChatGPTModel> get copyWith =>
      throw _privateConstructorUsedError;
}
