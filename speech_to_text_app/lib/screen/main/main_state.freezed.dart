// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MainState {
  List<TranscriptionEntry> get transcriptionHistory =>
      throw _privateConstructorUsedError;
  List<AudioFile> get audioFiles => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  RecordingState get recordingState => throw _privateConstructorUsedError;
  String? get audioPath => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MainStateCopyWith<MainState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MainStateCopyWith<$Res> {
  factory $MainStateCopyWith(MainState value, $Res Function(MainState) then) =
      _$MainStateCopyWithImpl<$Res, MainState>;
  @useResult
  $Res call(
      {List<TranscriptionEntry> transcriptionHistory,
      List<AudioFile> audioFiles,
      bool isLoading,
      RecordingState recordingState,
      String? audioPath});
}

/// @nodoc
class _$MainStateCopyWithImpl<$Res, $Val extends MainState>
    implements $MainStateCopyWith<$Res> {
  _$MainStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transcriptionHistory = null,
    Object? audioFiles = null,
    Object? isLoading = null,
    Object? recordingState = null,
    Object? audioPath = freezed,
  }) {
    return _then(_value.copyWith(
      transcriptionHistory: null == transcriptionHistory
          ? _value.transcriptionHistory
          : transcriptionHistory // ignore: cast_nullable_to_non_nullable
              as List<TranscriptionEntry>,
      audioFiles: null == audioFiles
          ? _value.audioFiles
          : audioFiles // ignore: cast_nullable_to_non_nullable
              as List<AudioFile>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      recordingState: null == recordingState
          ? _value.recordingState
          : recordingState // ignore: cast_nullable_to_non_nullable
              as RecordingState,
      audioPath: freezed == audioPath
          ? _value.audioPath
          : audioPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MainStateImplCopyWith<$Res>
    implements $MainStateCopyWith<$Res> {
  factory _$$MainStateImplCopyWith(
          _$MainStateImpl value, $Res Function(_$MainStateImpl) then) =
      __$$MainStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<TranscriptionEntry> transcriptionHistory,
      List<AudioFile> audioFiles,
      bool isLoading,
      RecordingState recordingState,
      String? audioPath});
}

/// @nodoc
class __$$MainStateImplCopyWithImpl<$Res>
    extends _$MainStateCopyWithImpl<$Res, _$MainStateImpl>
    implements _$$MainStateImplCopyWith<$Res> {
  __$$MainStateImplCopyWithImpl(
      _$MainStateImpl _value, $Res Function(_$MainStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transcriptionHistory = null,
    Object? audioFiles = null,
    Object? isLoading = null,
    Object? recordingState = null,
    Object? audioPath = freezed,
  }) {
    return _then(_$MainStateImpl(
      transcriptionHistory: null == transcriptionHistory
          ? _value._transcriptionHistory
          : transcriptionHistory // ignore: cast_nullable_to_non_nullable
              as List<TranscriptionEntry>,
      audioFiles: null == audioFiles
          ? _value._audioFiles
          : audioFiles // ignore: cast_nullable_to_non_nullable
              as List<AudioFile>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      recordingState: null == recordingState
          ? _value.recordingState
          : recordingState // ignore: cast_nullable_to_non_nullable
              as RecordingState,
      audioPath: freezed == audioPath
          ? _value.audioPath
          : audioPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$MainStateImpl implements _MainState {
  const _$MainStateImpl(
      {final List<TranscriptionEntry> transcriptionHistory = const [],
      final List<AudioFile> audioFiles = const [],
      this.isLoading = false,
      this.recordingState = RecordingState.idle,
      this.audioPath})
      : _transcriptionHistory = transcriptionHistory,
        _audioFiles = audioFiles;

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
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final RecordingState recordingState;
  @override
  final String? audioPath;

  @override
  String toString() {
    return 'MainState(transcriptionHistory: $transcriptionHistory, audioFiles: $audioFiles, isLoading: $isLoading, recordingState: $recordingState, audioPath: $audioPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MainStateImpl &&
            const DeepCollectionEquality()
                .equals(other._transcriptionHistory, _transcriptionHistory) &&
            const DeepCollectionEquality()
                .equals(other._audioFiles, _audioFiles) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.recordingState, recordingState) ||
                other.recordingState == recordingState) &&
            (identical(other.audioPath, audioPath) ||
                other.audioPath == audioPath));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_transcriptionHistory),
      const DeepCollectionEquality().hash(_audioFiles),
      isLoading,
      recordingState,
      audioPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MainStateImplCopyWith<_$MainStateImpl> get copyWith =>
      __$$MainStateImplCopyWithImpl<_$MainStateImpl>(this, _$identity);
}

abstract class _MainState implements MainState {
  const factory _MainState(
      {final List<TranscriptionEntry> transcriptionHistory,
      final List<AudioFile> audioFiles,
      final bool isLoading,
      final RecordingState recordingState,
      final String? audioPath}) = _$MainStateImpl;

  @override
  List<TranscriptionEntry> get transcriptionHistory;
  @override
  List<AudioFile> get audioFiles;
  @override
  bool get isLoading;
  @override
  RecordingState get recordingState;
  @override
  String? get audioPath;
  @override
  @JsonKey(ignore: true)
  _$$MainStateImplCopyWith<_$MainStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
