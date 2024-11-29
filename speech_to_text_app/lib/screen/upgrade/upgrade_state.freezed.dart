// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upgrade_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UpgradeState {
  bool get isLoading => throw _privateConstructorUsedError;
  String get zpTransToken => throw _privateConstructorUsedError;
  String get orderUrl => throw _privateConstructorUsedError;
  String get payResult => throw _privateConstructorUsedError;
  bool get showResult => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UpgradeStateCopyWith<UpgradeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpgradeStateCopyWith<$Res> {
  factory $UpgradeStateCopyWith(
          UpgradeState value, $Res Function(UpgradeState) then) =
      _$UpgradeStateCopyWithImpl<$Res, UpgradeState>;
  @useResult
  $Res call(
      {bool isLoading,
      String zpTransToken,
      String orderUrl,
      String payResult,
      bool showResult});
}

/// @nodoc
class _$UpgradeStateCopyWithImpl<$Res, $Val extends UpgradeState>
    implements $UpgradeStateCopyWith<$Res> {
  _$UpgradeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? zpTransToken = null,
    Object? orderUrl = null,
    Object? payResult = null,
    Object? showResult = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      zpTransToken: null == zpTransToken
          ? _value.zpTransToken
          : zpTransToken // ignore: cast_nullable_to_non_nullable
              as String,
      orderUrl: null == orderUrl
          ? _value.orderUrl
          : orderUrl // ignore: cast_nullable_to_non_nullable
              as String,
      payResult: null == payResult
          ? _value.payResult
          : payResult // ignore: cast_nullable_to_non_nullable
              as String,
      showResult: null == showResult
          ? _value.showResult
          : showResult // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpgradeStateImplCopyWith<$Res>
    implements $UpgradeStateCopyWith<$Res> {
  factory _$$UpgradeStateImplCopyWith(
          _$UpgradeStateImpl value, $Res Function(_$UpgradeStateImpl) then) =
      __$$UpgradeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      String zpTransToken,
      String orderUrl,
      String payResult,
      bool showResult});
}

/// @nodoc
class __$$UpgradeStateImplCopyWithImpl<$Res>
    extends _$UpgradeStateCopyWithImpl<$Res, _$UpgradeStateImpl>
    implements _$$UpgradeStateImplCopyWith<$Res> {
  __$$UpgradeStateImplCopyWithImpl(
      _$UpgradeStateImpl _value, $Res Function(_$UpgradeStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? zpTransToken = null,
    Object? orderUrl = null,
    Object? payResult = null,
    Object? showResult = null,
  }) {
    return _then(_$UpgradeStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      zpTransToken: null == zpTransToken
          ? _value.zpTransToken
          : zpTransToken // ignore: cast_nullable_to_non_nullable
              as String,
      orderUrl: null == orderUrl
          ? _value.orderUrl
          : orderUrl // ignore: cast_nullable_to_non_nullable
              as String,
      payResult: null == payResult
          ? _value.payResult
          : payResult // ignore: cast_nullable_to_non_nullable
              as String,
      showResult: null == showResult
          ? _value.showResult
          : showResult // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$UpgradeStateImpl extends _UpgradeState {
  _$UpgradeStateImpl(
      {this.isLoading = false,
      this.zpTransToken = '',
      this.orderUrl = '',
      this.payResult = '',
      this.showResult = false})
      : super._();

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final String zpTransToken;
  @override
  @JsonKey()
  final String orderUrl;
  @override
  @JsonKey()
  final String payResult;
  @override
  @JsonKey()
  final bool showResult;

  @override
  String toString() {
    return 'UpgradeState(isLoading: $isLoading, zpTransToken: $zpTransToken, orderUrl: $orderUrl, payResult: $payResult, showResult: $showResult)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpgradeStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.zpTransToken, zpTransToken) ||
                other.zpTransToken == zpTransToken) &&
            (identical(other.orderUrl, orderUrl) ||
                other.orderUrl == orderUrl) &&
            (identical(other.payResult, payResult) ||
                other.payResult == payResult) &&
            (identical(other.showResult, showResult) ||
                other.showResult == showResult));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, isLoading, zpTransToken, orderUrl, payResult, showResult);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpgradeStateImplCopyWith<_$UpgradeStateImpl> get copyWith =>
      __$$UpgradeStateImplCopyWithImpl<_$UpgradeStateImpl>(this, _$identity);
}

abstract class _UpgradeState extends UpgradeState {
  factory _UpgradeState(
      {final bool isLoading,
      final String zpTransToken,
      final String orderUrl,
      final String payResult,
      final bool showResult}) = _$UpgradeStateImpl;
  _UpgradeState._() : super._();

  @override
  bool get isLoading;
  @override
  String get zpTransToken;
  @override
  String get orderUrl;
  @override
  String get payResult;
  @override
  bool get showResult;
  @override
  @JsonKey(ignore: true)
  _$$UpgradeStateImplCopyWith<_$UpgradeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
