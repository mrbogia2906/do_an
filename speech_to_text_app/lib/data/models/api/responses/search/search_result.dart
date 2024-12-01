import '../../../../../screen/main/main_state.dart';
import '../audio_file/audio_file.dart';

class SearchResult {
  final AudioFile audio;
  final TranscriptionEntry transcription;

  SearchResult({required this.audio, required this.transcription});

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
        audio: AudioFile.fromJson(json['audio']),
        transcription: TranscriptionEntry.fromJson(json['transcription']));
  }
}
