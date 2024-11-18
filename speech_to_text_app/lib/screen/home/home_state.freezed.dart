// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HomeState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<TranscriptionEntry> get transcriptionHistory =>
      throw _privateConstructorUsedError;
  List<AudioFile> get audioFiles => throw _privateConstructorUsedError;
  String? get audioPath => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HomeStateCopyWith<HomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) then) =
      _$HomeStateCopyWithImpl<$Res, HomeState>;
  @useResult
  $Res call(
      {bool isLoading,
      List<TranscriptionEntry> transcriptionHistory,
      List<AudioFile> audioFiles,
      String? audioPath});
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res, $Val extends HomeState>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? transcriptionHistory = null,
    Object? audioFiles = null,
    Object? audioPath = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      transcriptionHistory: null == transcriptionHistory
          ? _value.transcriptionHistory
          : transcriptionHistory // ignore: cast_nullable_to_non_nullable
              as List<TranscriptionEntry>,
      audioFiles: null == audioFiles
          ? _value.audioFiles
          : audioFiles // ignore: cast_nullable_to_non_nullable
              as List<AudioFile>,
      audioPath: freezed == audioPath
          ? _value.audioPath
          : audioPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomeStateImplCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory _$$HomeStateImplCopyWith(
          _$HomeStateImpl value, $Res Function(_$HomeStateImpl) then) =
      __$$HomeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      List<TranscriptionEntry> transcriptionHistory,
      List<AudioFile> audioFiles,
      String? audioPath});
}

/// @nodoc
class __$$HomeStateImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeStateImpl>
    implements _$$HomeStateImplCopyWith<$Res> {
  __$$HomeStateImplCopyWithImpl(
      _$HomeStateImpl _value, $Res Function(_$HomeStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? transcriptionHistory = null,
    Object? audioFiles = null,
    Object? audioPath = freezed,
  }) {
    return _then(_$HomeStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      transcriptionHistory: null == transcriptionHistory
          ? _value._transcriptionHistory
          : transcriptionHistory // ignore: cast_nullable_to_non_nullable
              as List<TranscriptionEntry>,
      audioFiles: null == audioFiles
          ? _value._audioFiles
          : audioFiles // ignore: cast_nullable_to_non_nullable
              as List<AudioFile>,
      audioPath: freezed == audioPath
          ? _value.audioPath
          : audioPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$HomeStateImpl extends _HomeState {
  _$HomeStateImpl(
      {this.isLoading = true,
      final List<TranscriptionEntry> transcriptionHistory = const [],
      final List<AudioFile> audioFiles = const [],
      this.audioPath})
      : _transcriptionHistory = transcriptionHistory,
        _audioFiles = audioFiles,
        super._();

  @override
  @JsonKey()
  final bool isLoading;
  final List<TranscriptionEntry> _transcriptionHistory;
  @override
  @JsonKey()
  List<TranscriptionEntry> get transcriptionHistory {
    if (_transcriptionHistory is EqualUnmodifiableListView)
      return _transcriptionHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transcriptionHistory);
  }

  final List<AudioFile> _audioFiles;
  @override
  @JsonKey()
  List<AudioFile> get audioFiles {
    if (_audioFiles is EqualUnmodifiableListView) return _audioFiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_audioFiles);
  }

  @override
  final String? audioPath;

  @override
  String toString() {
    return 'HomeState(isLoading: $isLoading, transcriptionHistory: $transcriptionHistory, audioFiles: $audioFiles, audioPath: $audioPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality()
                .equals(other._transcriptionHistory, _transcriptionHistory) &&
            const DeepCollectionEquality()
                .equals(other._audioFiles, _audioFiles) &&
            (identical(other.audioPath, audioPath) ||
                other.audioPath == audioPath));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      const DeepCollectionEquality().hash(_transcriptionHistory),
      const DeepCollectionEquality().hash(_audioFiles),
      audioPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      __$$HomeStateImplCopyWithImpl<_$HomeStateImpl>(this, _$identity);
}

abstract class _HomeState extends HomeState {
  factory _HomeState(
      {final bool isLoading,
      final List<TranscriptionEntry> transcriptionHistory,
      final List<AudioFile> audioFiles,
      final String? audioPath}) = _$HomeStateImpl;
  _HomeState._() : super._();

  @override
  bool get isLoading;
  @override
  List<TranscriptionEntry> get transcriptionHistory;
  @override
  List<AudioFile> get audioFiles;
  @override
  String? get audioPath;
  @override
  @JsonKey(ignore: true)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
