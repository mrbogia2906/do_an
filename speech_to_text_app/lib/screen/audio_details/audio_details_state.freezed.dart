// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_details_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AudioDetailsState {
  bool get loading => throw _privateConstructorUsedError;
  List<TranscriptionEntry> get transcriptionHistory =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AudioDetailsStateCopyWith<AudioDetailsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioDetailsStateCopyWith<$Res> {
  factory $AudioDetailsStateCopyWith(
          AudioDetailsState value, $Res Function(AudioDetailsState) then) =
      _$AudioDetailsStateCopyWithImpl<$Res, AudioDetailsState>;
  @useResult
  $Res call({bool loading, List<TranscriptionEntry> transcriptionHistory});
}

/// @nodoc
class _$AudioDetailsStateCopyWithImpl<$Res, $Val extends AudioDetailsState>
    implements $AudioDetailsStateCopyWith<$Res> {
  _$AudioDetailsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loading = null,
    Object? transcriptionHistory = null,
  }) {
    return _then(_value.copyWith(
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
      transcriptionHistory: null == transcriptionHistory
          ? _value.transcriptionHistory
          : transcriptionHistory // ignore: cast_nullable_to_non_nullable
              as List<TranscriptionEntry>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AudioDetailsStateImplCopyWith<$Res>
    implements $AudioDetailsStateCopyWith<$Res> {
  factory _$$AudioDetailsStateImplCopyWith(_$AudioDetailsStateImpl value,
          $Res Function(_$AudioDetailsStateImpl) then) =
      __$$AudioDetailsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool loading, List<TranscriptionEntry> transcriptionHistory});
}

/// @nodoc
class __$$AudioDetailsStateImplCopyWithImpl<$Res>
    extends _$AudioDetailsStateCopyWithImpl<$Res, _$AudioDetailsStateImpl>
    implements _$$AudioDetailsStateImplCopyWith<$Res> {
  __$$AudioDetailsStateImplCopyWithImpl(_$AudioDetailsStateImpl _value,
      $Res Function(_$AudioDetailsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loading = null,
    Object? transcriptionHistory = null,
  }) {
    return _then(_$AudioDetailsStateImpl(
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
      transcriptionHistory: null == transcriptionHistory
          ? _value._transcriptionHistory
          : transcriptionHistory // ignore: cast_nullable_to_non_nullable
              as List<TranscriptionEntry>,
    ));
  }
}

/// @nodoc

class _$AudioDetailsStateImpl extends _AudioDetailsState {
  _$AudioDetailsStateImpl(
      {this.loading = true,
      final List<TranscriptionEntry> transcriptionHistory = const []})
      : _transcriptionHistory = transcriptionHistory,
        super._();

  @override
  @JsonKey()
  final bool loading;
  final List<TranscriptionEntry> _transcriptionHistory;
  @override
  @JsonKey()
  List<TranscriptionEntry> get transcriptionHistory {
    if (_transcriptionHistory is EqualUnmodifiableListView)
      return _transcriptionHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transcriptionHistory);
  }

  @override
  String toString() {
    return 'AudioDetailsState(loading: $loading, transcriptionHistory: $transcriptionHistory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioDetailsStateImpl &&
            (identical(other.loading, loading) || other.loading == loading) &&
            const DeepCollectionEquality()
                .equals(other._transcriptionHistory, _transcriptionHistory));
  }

  @override
  int get hashCode => Object.hash(runtimeType, loading,
      const DeepCollectionEquality().hash(_transcriptionHistory));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioDetailsStateImplCopyWith<_$AudioDetailsStateImpl> get copyWith =>
      __$$AudioDetailsStateImplCopyWithImpl<_$AudioDetailsStateImpl>(
          this, _$identity);
}

abstract class _AudioDetailsState extends AudioDetailsState {
  factory _AudioDetailsState(
          {final bool loading,
          final List<TranscriptionEntry> transcriptionHistory}) =
      _$AudioDetailsStateImpl;
  _AudioDetailsState._() : super._();

  @override
  bool get loading;
  @override
  List<TranscriptionEntry> get transcriptionHistory;
  @override
  @JsonKey(ignore: true)
  _$$AudioDetailsStateImplCopyWith<_$AudioDetailsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
