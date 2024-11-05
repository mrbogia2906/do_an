import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view_model.dart';
import 'package:speech_to_text_app/screen/home/home_state.dart';
import 'package:http/http.dart' as http;

import '../main/main_screen.dart';
import '../main/main_state.dart';
import '../main/main_view_model.dart';

class HomeViewModel extends BaseViewModel<HomeState> {
  HomeViewModel({required this.ref}) : super(HomeState()) {
    // Khởi tạo dữ liệu ban đầu
    initData();

    // Lắng nghe sự thay đổi của mainProvider
    ref.listen<MainState>(mainProvider, (previous, next) {
      state = state.copyWith(
        audioPath: next.audioPath,
      );
    });
  }
  Ref ref;

  Future<void> initData() async {
    final mainState = ref.watch(mainProvider);
    state = state.copyWith(
      audioPath: mainState.audioPath,
    );
  }

  Future<void> sendToTranscription(String endpoint) async {
    if (state.audioPath == null) return;

    state = state.copyWith(loading: true);

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
        loading: false,
      );
    } else {
      state = state.copyWith(loading: false);
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

  Future<void> pickAudioFile3(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      state = state.copyWith(audioPath: result.files.single.path);

      Navigator.pop(context);

      // await sendToTranscription('gemini-transcribe');

      print('Audio file selected: ${state.audioPath}');
    } else {
      print('No file selected');
    }
  }

  void _initialize() {
    // Watch MainViewModel's transcription history
    final mainViewModel = ref.watch(mainProvider.notifier);
    final mainState = ref.watch(mainProvider);
    state = state.copyWith(
      transcriptionHistory: mainState.transcriptionHistory,
    );

    // Listen to changes in MainViewModel and update HomeState
    ref.listen(mainProvider, (previous, next) {
      state = state.copyWith(
        transcriptionHistory: next.transcriptionHistory,
      );
    });
  }

  void updateState() {
    state = state.copyWith(loading: false);
  }
}
