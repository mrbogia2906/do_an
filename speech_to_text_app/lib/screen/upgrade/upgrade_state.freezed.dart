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
  bool get loading => throw _privateConstructorUsedError;

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
  $Res call({bool loading});
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
    Object? loading = null,
  }) {
    return _then(_value.copyWith(
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
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
  $Res call({bool loading});
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
    Object? loading = null,
  }) {
    return _then(_$UpgradeStateImpl(
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$UpgradeStateImpl extends _UpgradeState {
  _$UpgradeStateImpl({this.loading = true}) : super._();

  @override
  @JsonKey()
  final bool loading;

  @override
  String toString() {
    return 'UpgradeState(loading: $loading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpgradeStateImpl &&
            (identical(other.loading, loading) || other.loading == loading));
  }

  @override
  int get hashCode => Object.hash(runtimeType, loading);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpgradeStateImplCopyWith<_$UpgradeStateImpl> get copyWith =>
      __$$UpgradeStateImplCopyWithImpl<_$UpgradeStateImpl>(this, _$identity);
}

abstract class _UpgradeState extends UpgradeState {
  factory _UpgradeState({final bool loading}) = _$UpgradeStateImpl;
  _UpgradeState._() : super._();

  @override
  bool get loading;
  @override
  @JsonKey(ignore: true)
  _$$UpgradeStateImplCopyWith<_$UpgradeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
