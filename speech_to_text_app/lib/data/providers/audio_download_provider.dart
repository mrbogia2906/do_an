import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/data/services/api/audio_download_manager.dart';

final audioDownloadProvider = Provider<AudioDownloadManager>((ref) {
  return AudioDownloadManager();
});
