import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../components/base_view/base_view_model.dart';
import 'main_state.dart';

class MainViewModel extends BaseViewModel<MainState> {
  MainViewModel({required this.ref}) : super(MainState());

  final Ref ref;
  FlutterSoundRecorder? _recorder;
  String? _audioPath;

  Future<void> initRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
  }

  Future<void> startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/audio';
    await _recorder!.startRecorder(toFile: path);
    _audioPath = path;
    state = state.copyWith(recordingState: RecordingState.recording);
  }

  Future<void> stopRecording() async {
    await _recorder!.stopRecorder();
    state = state.copyWith(recordingState: RecordingState.idle);
  }

  Future<void> pauseRecording() async {
    await _recorder!.pauseRecorder();
    state = state.copyWith(recordingState: RecordingState.paused);
  }

  Future<void> resumeRecording() async {
    await _recorder!.resumeRecorder();
    state = state.copyWith(recordingState: RecordingState.recording);
  }

  Future<void> sendToTranscription(String endpoint) async {
    if (state.audioPath == null) return;

    state = state.copyWith(isLoading: true);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.10.180.39:3000/$endpoint'),
    );
    request.files
        .add(await http.MultipartFile.fromPath('audio', state.audioPath!));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await http.Response.fromStream(response);
      var data = json.decode(responseBody.body);

      // Save transcription result
      String transcriptionText = data['transcription'];
      // _saveTranscription("New Transcription", transcriptionText);

      // Update the state to include the new transcription
      state = state.copyWith(
        transcriptionHistory: [
          TranscriptionEntry(
            title: "New Transcription",
            content: transcriptionText,
            timestamp: DateTime.now(),
          ),
          ...state.transcriptionHistory,
        ],
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
      print('Error: Unable to transcribe audio');
    }
  }

  Future<void> _saveTranscription(String title, String content) async {
    final entry = TranscriptionEntry(
      title: title,
      content: content,
      timestamp: DateTime.now(),
    );

    // Update the local state with the new transcription
    state = state.copyWith(
      transcriptionHistory: [
        entry,
        ...state.transcriptionHistory,
      ],
    );
  }

  // Method to pick and set an audio file
  Future<void> pickAudioFile(String path) async {
    _audioPath = path;
  }

  Future<void> pickAudioFile2(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      state =
          state.copyWith(audioPath: result.files.single.path, isLoading: true);

      Navigator.pop(context);

      await sendToTranscription('gemini-transcribe');

      print('Audio file selected: ${state.audioPath}');
    } else {
      print('No file selected');
    }
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    super.dispose();
  }
}
