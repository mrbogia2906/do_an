// lib/screen/main/main_view_model.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:uuid/uuid.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

import '../../components/base_view/base_view_model.dart';
import '../../data/providers/audio_download_provider.dart';
import '../../data/providers/audio_provider.dart';
import '../../data/providers/transcription_provider.dart';
import '../../data/repositories/auth/auth_local_repository.dart';
import '../../data/services/audio_service/audio_service.dart';

import '../../data/view_model/auth_viewmodel.dart';
import '../../utilities/global.dart';
import 'main_state.dart';

class MainViewModel extends BaseViewModel<MainState> {
  MainViewModel({
    required this.ref,
    required this.authViewModel,
  }) : super(const MainState());
  // {
  //   _init();
  //   // fetchAudioFiles(); // Fetch existing audio files when ViewModel is initialized
  // }

  final Ref ref;
  final AudioService _audioService = AudioService();
  AuthViewModel authViewModel;
  // FlutterSoundRecorder? _audioRecorder;

  final RecorderController recorderController = RecorderController();

  @override
  void dispose() {
    recorderController.dispose();

    super.dispose();
  }

  Future<void> startRecording() async {
    // Check and request microphone permission
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        // Permission not granted
        return;
      }
    }

    // Set the file path for recording
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String filePath =
        '${appDirectory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    // Start recording
    await recorderController.record(path: filePath);

    // Update state
    state = state.copyWith(
      recordingState: RecordingState.recording,
      audioPath: filePath,
    );
  }

  Future<void> pauseRecording() async {
    await recorderController.pause();
    state = state.copyWith(recordingState: RecordingState.paused);
  }

  Future<void> resumeRecording() async {
    await recorderController.record();
    state = state.copyWith(recordingState: RecordingState.recording);
  }

  Future<void> stopRecording(BuildContext context) async {
    final path = await recorderController.stop();
    state = state.copyWith(
      recordingState: RecordingState.idle,
      audioPath: path,
    );

    if (path != null) {
      // Create tempId and initial TranscriptionEntry
      final tempId = Uuid().v4();
      final processingEntry = TranscriptionEntry(
        id: tempId,
        transcriptionId: null,
        audioFileId: 'Recording',
        content: 'Processing audio file...',
        summary: 'Processing audio file...',
        words: [],
        createdAt: DateTime.now(),
        isProcessing: true,
        isError: false,
      );
      ref
          .read(transcriptionProvider.notifier)
          .addTranscription(processingEntry);

      // Get token from AuthLocalRepository
      final token = await ref.read(authLocalRepositoryProvider).getToken();
      if (token == null) {
        // Update TranscriptionEntry with error
        ref.read(transcriptionProvider.notifier).updateTranscriptionByTempId(
              tempId,
              processingEntry.copyWith(
                content: 'Authentication token missing',
                summary: 'Authentication token missing',
                isProcessing: false,
                isError: true,
              ),
            );

        // Show Snackbar
        if (scaffoldMessengerKey.currentState != null) {
          scaffoldMessengerKey.currentState!.showSnackBar(
            const SnackBar(content: Text('Authentication token missing.')),
          );
        }
        return;
      }

      try {
        final audioFile = File(path);
        final uploadedAudio = await _audioService.uploadAudio(
          audioFile,
          'Recording_${DateTime.now().millisecondsSinceEpoch}',
          token,
        );

        if (uploadedAudio.transcriptionId != null) {
          // Update TranscriptionEntry with id from backend
          final updatedEntry = processingEntry.copyWith(
            id: uploadedAudio.transcriptionId!,
            transcriptionId: uploadedAudio.transcriptionId,
            audioFileId: uploadedAudio.id,
          );

          // Update in provider
          ref.read(transcriptionProvider.notifier).updateTranscriptionByTempId(
                tempId,
                updatedEntry,
              );

          // Add audioFile to audioFilesProvider
          ref.read(audioFilesProvider.notifier).addAudioFile(uploadedAudio);

          // Start polling transcription status
          pollTranscriptionStatus(
            uploadedAudio.id,
            uploadedAudio.transcriptionId!,
          );

          // Close modal after successful upload
          // Navigator.pop(context);
          // AutoRouter.of(context).pop();
        } else {
          // Handle missing transcriptionId
          ref.read(transcriptionProvider.notifier).updateTranscriptionByTempId(
                tempId,
                processingEntry.copyWith(
                  content: 'Transcription ID missing from backend',
                  summary: 'Transcription ID missing from backend',
                  isProcessing: false,
                  isError: true,
                ),
              );

          // Show Snackbar
          if (scaffoldMessengerKey.currentState != null) {
            scaffoldMessengerKey.currentState!.showSnackBar(
              const SnackBar(
                  content: Text('Transcription ID missing from backend.')),
            );
          }
        }
      } catch (e) {
        debugPrint('Error uploading audio: $e');

        // Update TranscriptionEntry with error
        ref.read(transcriptionProvider.notifier).updateTranscriptionByTempId(
              tempId,
              processingEntry.copyWith(
                content: e.toString(),
                summary: e.toString(),
                isProcessing: false,
                isError: true,
              ),
            );

        // Show Snackbar
        if (scaffoldMessengerKey.currentState != null) {
          scaffoldMessengerKey.currentState!.showSnackBar(
            SnackBar(content: Text('Error uploading audio: $e')),
          );
        }
      }
    }
  }

  String sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(' ', '_');
  }

  Future<void> pickAudioFile2(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      String? filePath = result.files.single.path;
      if (filePath == null) {
        debugPrint('Selected file path is null.');
        if (scaffoldMessengerKey.currentState != null) {
          scaffoldMessengerKey.currentState!.showSnackBar(
            const SnackBar(content: Text('Failed to get file path.')),
          );
        }

        return;
      }

      state = state.copyWith(audioPath: filePath);

      final fileName = result.files.single.name;
      final token = await ref.read(authLocalRepositoryProvider).getToken();
      if (token == null) {
        // Handle missing token
        return;
      }

      // Tạo tempId
      final tempId = Uuid().v4();

      // Tạo TranscriptionEntry ban đầu với tempId
      final processingEntry = TranscriptionEntry(
        id: tempId,
        transcriptionId: null,
        audioFileId: fileName,
        content: 'Processing audio file...',
        summary: 'Processing audio file...',
        words: [],
        createdAt: DateTime.now(),
        isProcessing: true,
        isError: false,
      );

      // Thêm vào provider
      ref
          .read(transcriptionProvider.notifier)
          .addTranscription(processingEntry);

      try {
        final audioFile = File(filePath);
        final uploadedAudio = await _audioService.uploadAudio(
          audioFile,
          fileName,
          token,
        );

        // final uploadedTrancription =
        //     await _audioService.uploadAudioWithGoogleSTT(
        //   audioFile,
        //   fileName,
        //   token,
        // );

        // Cập nhật TranscriptionEntry với id từ backend
        final updatedEntry = processingEntry.copyWith(
          id: uploadedAudio.transcriptionId!, // Cập nhật id
          transcriptionId: uploadedAudio.transcriptionId,
          audioFileId: uploadedAudio.id,
        );

        // Cập nhật trong provider
        ref.read(transcriptionProvider.notifier).updateTranscriptionByTempId(
              tempId,
              updatedEntry,
            );

        // Bắt đầu polling trạng thái phiên âm
        pollTranscriptionStatus(
          uploadedAudio.id,
          uploadedAudio.transcriptionId!,
        );
        authViewModel.getCurrentUserData();

        // Thêm audioFile vào audioFilesProvider
        ref.read(audioFilesProvider.notifier).addAudioFile(uploadedAudio);
      } catch (e) {
        // Xử lý lỗi
        ref.read(transcriptionProvider.notifier).updateTranscriptionByTempId(
              tempId,
              processingEntry.copyWith(
                content: e.toString(),
                summary: e.toString(),
                isProcessing: false,
                isError: true,
              ),
            );
        if (scaffoldMessengerKey.currentState != null) {
          scaffoldMessengerKey.currentState!.showSnackBar(
            SnackBar(content: Text('Error uploading audio: $e')),
          );
        }
      }
    } else {
      debugPrint('No file selected or file path is null');
      if (scaffoldMessengerKey.currentState != null) {
        scaffoldMessengerKey.currentState!.showSnackBar(
          const SnackBar(content: Text('No file selected.')),
        );
      }
    }
  }

  Future<void> checkAndDownloadAudio(String key, BuildContext context) async {
    final yt = YoutubeExplode();
    String videoTitle;

    try {
      var video = await yt.videos.get('https://youtube.com/watch?v=$key');
      videoTitle = video.title;
    } catch (e) {
      debugPrint('Error retrieving video title: $e');
      videoTitle = 'YouTube Video';
    } finally {
      yt.close();
    }

    final cacheDir = await getTemporaryDirectory();
    final sanitizedTitle = sanitizeFileName(videoTitle);
    final savePath = '${cacheDir.path}/$sanitizedTitle.mp3';
    final file = File(savePath);

    // Tạo tempId và TranscriptionEntry ban đầu
    final tempId = Uuid().v4();
    final processingEntry = TranscriptionEntry(
      id: tempId,
      transcriptionId: null,
      audioFileId: sanitizedTitle,
      content: 'Processing audio file...',
      summary: 'Processing audio file...',
      words: [],
      createdAt: DateTime.now(),
      isProcessing: true,
      isError: false,
    );
    ref.read(transcriptionProvider.notifier).addTranscription(processingEntry);

    if (!await file.exists()) {
      final audioDownloadManager = ref.read(audioDownloadProvider);
      try {
        await audioDownloadManager.downloadAudioInBackground(key, videoTitle);
      } catch (e) {
        debugPrint('Error downloading audio: $e');

        // Cập nhật TranscriptionEntry với lỗi
        ref.read(transcriptionProvider.notifier).updateTranscriptionByTempId(
              tempId,
              processingEntry.copyWith(
                content: e.toString(),
                summary: e.toString(),
                isProcessing: false,
                isError: true,
              ),
            );

        // Hiển thị SnackBar
        if (scaffoldMessengerKey.currentState != null) {
          scaffoldMessengerKey.currentState!.showSnackBar(
            SnackBar(content: Text('Error downloading audio: $e')),
          );
        }

        return;
      }
    }

    if (await file.exists()) {
      final token = await ref.read(authLocalRepositoryProvider).getToken();
      if (token == null) {
        // Cập nhật TranscriptionEntry với lỗi
        ref.read(transcriptionProvider.notifier).updateTranscriptionByTempId(
              tempId,
              processingEntry.copyWith(
                content: 'Authentication token missing',
                summary: 'Authentication token missing',
                isProcessing: false,
                isError: true,
              ),
            );

        // Hiển thị SnackBar
        if (scaffoldMessengerKey.currentState != null) {
          scaffoldMessengerKey.currentState!.showSnackBar(
            const SnackBar(content: Text('Authentication token missing')),
          );
        }

        return;
      }

      try {
        final audioFile = File(savePath);
        final uploadedAudio = await _audioService.uploadAudio(
          audioFile,
          videoTitle,
          token,
        );

        if (uploadedAudio.transcriptionId != null) {
          // Cập nhật TranscriptionEntry với id từ backend
          final updatedEntry = processingEntry.copyWith(
            id: uploadedAudio.transcriptionId!, // Cập nhật id
            transcriptionId: uploadedAudio.transcriptionId,
            audioFileId: uploadedAudio.id,
          );

          // Cập nhật trong provider
          ref.read(transcriptionProvider.notifier).updateTranscriptionByTempId(
                tempId,
                updatedEntry,
              );

          // Thêm audioFile vào audioFilesProvider
          ref.read(audioFilesProvider.notifier).addAudioFile(uploadedAudio);

          // Bắt đầu polling trạng thái phiên âm
          pollTranscriptionStatus(
            uploadedAudio.id,
            uploadedAudio.transcriptionId!,
          );

          // Đóng bottom sheet nếu cần
          authViewModel.getCurrentUserData();

          Navigator.pop(context);
        } else {
          // Nếu không có transcriptionId, xử lý lỗi
          print('uploadedAudio.transcriptionId is null');

          // Cập nhật TranscriptionEntry với lỗi
          ref.read(transcriptionProvider.notifier).updateTranscriptionByTempId(
                tempId,
                processingEntry.copyWith(
                  content: 'Transcription ID missing from backend',
                  summary: 'Transcription ID missing from backend',
                  isProcessing: false,
                  isError: true,
                ),
              );

          // Hiển thị SnackBar
          if (scaffoldMessengerKey.currentState != null) {
            scaffoldMessengerKey.currentState!.showSnackBar(
              SnackBar(content: Text('Transcription ID missing from backend.')),
            );
          }
        }
      } catch (e) {
        print('Error uploading audio: $e');

        // Cập nhật TranscriptionEntry với lỗi
        ref.read(transcriptionProvider.notifier).updateTranscriptionByTempId(
              tempId,
              processingEntry.copyWith(
                content: e.toString(),
                summary: e.toString(),
                isProcessing: false,
                isError: true,
              ),
            );

        // Hiển thị SnackBar
        // if (scaffoldMessengerKey.currentState != null) {
        //   scaffoldMessengerKey.currentState!.showSnackBar(
        //     SnackBar(content: Text('Error uploading audio: $e')),
        //   );
        // }
      }
    } else {
      debugPrint('File does not exist after download');

      // Cập nhật TranscriptionEntry với lỗi
      ref.read(transcriptionProvider.notifier).updateTranscriptionByTempId(
            tempId,
            processingEntry.copyWith(
              content: 'File does not exist after download',
              summary: 'File does not exist after download',
              isProcessing: false,
              isError: true,
            ),
          );

      // Hiển thị SnackBar
      if (scaffoldMessengerKey.currentState != null) {
        scaffoldMessengerKey.currentState!.showSnackBar(
          const SnackBar(content: Text('File does not exist after download.')),
        );
      }
    }
  }

  // Phương thức polling trạng thái phiên âm
  Future<void> pollTranscriptionStatus(
      String audioFileId, String transcriptionId) async {
    if (transcriptionId.isEmpty) {
      debugPrint('pollTranscriptionStatus: transcriptionId is empty');
      return;
    }

    debugPrint(
        'Polling transcription status for transcription ID: $transcriptionId');

    final token = await ref.read(authLocalRepositoryProvider).getToken();
    if (token == null) {
      debugPrint('pollTranscriptionStatus: Token missing');
      ref.read(transcriptionProvider.notifier).updateTranscriptionByAudioFileId(
            audioFileId,
            TranscriptionEntry(
              id: transcriptionId, // Unique ID
              transcriptionId: transcriptionId,
              audioFileId: audioFileId,
              content: 'Authentication token missing',
              summary: 'Authentication token missing',
              words: [],
              createdAt: DateTime.now(),
              isProcessing: false,
              isError: true,
            ),
          );
      return;
    }

    try {
      final transcription =
          await _audioService.getTranscription(transcriptionId, token);
      debugPrint(
          'pollTranscriptionStatus: Fetched transcription - ${transcription.id} - isProcessing: ${transcription.isProcessing}');

      if (transcription.isError) {
        ref
            .read(transcriptionProvider.notifier)
            .updateTranscriptionByAudioFileId(
              audioFileId,
              TranscriptionEntry(
                id: transcriptionId,
                transcriptionId: transcription.transcriptionId,
                audioFileId: transcription.audioFileId,
                content: transcription.content ?? 'Unknown error',
                summary: transcription.summary ?? 'Unknown error',
                words: transcription.words,
                createdAt: transcription.createdAt,
                isProcessing: false,
                isError: true,
              ),
            );
        debugPrint(
            'pollTranscriptionStatus: Transcription error for ID: ${transcription.id}');
      } else if (!transcription.isProcessing) {
        ref
            .read(transcriptionProvider.notifier)
            .updateTranscriptionByAudioFileId(
              audioFileId,
              TranscriptionEntry(
                id: transcriptionId, // Unique ID
                transcriptionId: transcription.transcriptionId,
                audioFileId: transcription.audioFileId,
                content: transcription.content ?? 'No content',
                summary: transcription.summary ?? 'No summary',
                words: transcription.words,
                createdAt: transcription.createdAt,
                isProcessing: false,
                isError: false,
              ),
            );
        debugPrint(
            'pollTranscriptionStatus: Transcription completed for ID: ${transcription.id}');
      } else {
        // Nếu vẫn đang xử lý, tiếp tục polling sau 5 giây
        debugPrint(
            'pollTranscriptionStatus: Transcription still processing for ID: $transcriptionId. Polling again in 5 seconds.');
        await Future.delayed(const Duration(seconds: 5));
        await pollTranscriptionStatus(audioFileId, transcriptionId);
      }
    } catch (e) {
      debugPrint('Error polling transcription status: $e');
      ref.read(transcriptionProvider.notifier).updateTranscriptionByAudioFileId(
            audioFileId,
            TranscriptionEntry(
              id: transcriptionId, // Unique ID
              transcriptionId: transcriptionId,
              audioFileId: audioFileId,
              content: e.toString(),
              summary: e.toString(),
              words: [],
              createdAt: DateTime.now(),
              isProcessing: false,
              isError: true,
            ),
          );
    }
  }

  // Phương thức đăng xuất người dùng
  Future<void> logoutUser() async {
    await ref.read(authViewModelProvider.notifier).logoutUser();
    // Xóa các transcription entries khi đăng xuất
    ref.read(transcriptionProvider.notifier).clearTranscriptions();
    // Xóa audioFiles nếu cần
    ref.read(audioFilesProvider.notifier).clearAudioFiles();
  }
}
