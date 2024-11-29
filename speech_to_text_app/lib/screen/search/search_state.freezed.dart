// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SearchState {
  List<TranscriptionEntry> get transcriptionHistory =>
      throw _privateConstructorUsedError;
  List<AudioFile> get audioFiles => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  List<String> get searchQueryHistory => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SearchStateCopyWith<SearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchStateCopyWith<$Res> {
  factory $SearchStateCopyWith(
          SearchState value, $Res Function(SearchState) then) =
      _$SearchStateCopyWithImpl<$Res, SearchState>;
  @useResult
  $Res call(
      {List<TranscriptionEntry> transcriptionHistory,
      List<AudioFile> audioFiles,
      String searchQuery,
      List<String> searchQueryHistory});
}

/// @nodoc
class _$SearchStateCopyWithImpl<$Res, $Val extends SearchState>
    implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transcriptionHistory = null,
    Object? audioFiles = null,
    Object? searchQuery = null,
    Object? searchQueryHistory = null,
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
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      searchQueryHistory: null == searchQueryHistory
          ? _value.searchQueryHistory
          : searchQueryHistory // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchStateImplCopyWith<$Res>
    implements $SearchStateCopyWith<$Res> {
  factory _$$SearchStateImplCopyWith(
          _$SearchStateImpl value, $Res Function(_$SearchStateImpl) then) =
      __$$SearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<TranscriptionEntry> transcriptionHistory,
      List<AudioFile> audioFiles,
      String searchQuery,
      List<String> searchQueryHistory});
}

/// @nodoc
class __$$SearchStateImplCopyWithImpl<$Res>
    extends _$SearchStateCopyWithImpl<$Res, _$SearchStateImpl>
    implements _$$SearchStateImplCopyWith<$Res> {
  __$$SearchStateImplCopyWithImpl(
      _$SearchStateImpl _value, $Res Function(_$SearchStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transcriptionHistory = null,
    Object? audioFiles = null,
    Object? searchQuery = null,
    Object? searchQueryHistory = null,
  }) {
    return _then(_$SearchStateImpl(
      transcriptionHistory: null == transcriptionHistory
          ? _value._transcriptionHistory
          : transcriptionHistory // ignore: cast_nullable_to_non_nullable
              as List<TranscriptionEntry>,
      audioFiles: null == audioFiles
          ? _value._audioFiles
          : audioFiles // ignore: cast_nullable_to_non_nullable
              as List<AudioFile>,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      searchQueryHistory: null == searchQueryHistory
          ? _value._searchQueryHistory
          : searchQueryHistory // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$SearchStateImpl extends _SearchState {
  _$SearchStateImpl(
      {final List<TranscriptionEntry> transcriptionHistory = const [],
      final List<AudioFile> audioFiles = const [],
      this.searchQuery = '',
      final List<String> searchQueryHistory = const []})
      : _transcriptionHistory = transcriptionHistory,
        _audioFiles = audioFiles,
        _searchQueryHistory = searchQueryHistory,
        super._();

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
  final String searchQuery;
  final List<String> _searchQueryHistory;
  @override
  @JsonKey()
  List<String> get searchQueryHistory {
    if (_searchQueryHistory is EqualUnmodifiableListView)
      return _searchQueryHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_searchQueryHistory);
  }

  @override
  String toString() {
    return 'SearchState(transcriptionHistory: $transcriptionHistory, audioFiles: $audioFiles, searchQuery: $searchQuery, searchQueryHistory: $searchQueryHistory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchStateImpl &&
            const DeepCollectionEquality()
                .equals(other._transcriptionHistory, _transcriptionHistory) &&
            const DeepCollectionEquality()
                .equals(other._audioFiles, _audioFiles) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            const DeepCollectionEquality()
                .equals(other._searchQueryHistory, _searchQueryHistory));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_transcriptionHistory),
      const DeepCollectionEquality().hash(_audioFiles),
      searchQuery,
      const DeepCollectionEquality().hash(_searchQueryHistory));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      __$$SearchStateImplCopyWithImpl<_$SearchStateImpl>(this, _$identity);
}

abstract class _SearchState extends SearchState {
  factory _SearchState(
      {final List<TranscriptionEntry> transcriptionHistory,
      final List<AudioFile> audioFiles,
      final String searchQuery,
      final List<String> searchQueryHistory}) = _$SearchStateImpl;
  _SearchState._() : super._();

  @override
  List<TranscriptionEntry> get transcriptionHistory;
  @override
  List<AudioFile> get audioFiles;
  @override
  String get searchQuery;
  @override
  List<String> get searchQueryHistory;
  @override
  @JsonKey(ignore: true)
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
