import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudioDownloadManager {
  final YoutubeExplode _ytExplode = YoutubeExplode();
  final Map<String, Future<void>> _downloadTasks = {};

  String sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(' ', '_');
  }

  Future<void> downloadAudioInBackground(String key, String audioTitle) async {
    final cacheDir = await getTemporaryDirectory();
    final sanitizedTitle = sanitizeFileName(audioTitle);
    final tempSavePath = '${cacheDir.path}/${sanitizedTitle}_temp.mp3';
    final finalSavePath = '${cacheDir.path}/$sanitizedTitle.mp3';

    final file = File(finalSavePath);
    if (!await file.exists()) {
      if (_downloadTasks.containsKey(key)) {
        await _downloadTasks[key];
        return;
      }

      _downloadTasks[key] =
          _download(key, audioTitle, tempSavePath, finalSavePath);

      await _downloadTasks[key];
    }
  }

  Future<void> _download(
    String key,
    String audioTitle,
    String tempSavePath,
    String finalSavePath,
  ) async {
    try {
      // Tải video và lấy stream âm thanh
      print('Starting download for key: $key');
      var video =
          await _ytExplode.videos.get('https://youtube.com/watch?v=$key');
      print('Video title: ${video.title}');
      var manifest =
          await _ytExplode.videos.streamsClient.getManifest(video.id);

      var streamInfo = manifest.audioOnly.withHighestBitrate();

      var stream = _ytExplode.videos.streamsClient.get(streamInfo);
      await _saveStream(stream, tempSavePath);

      final tempFile = File(tempSavePath);
      await tempFile.rename(finalSavePath);

      print("Audio saved successfully to $finalSavePath");
    } catch (e) {
      print("Error downloading audio: $e");
      final tempFile = File(tempSavePath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      rethrow;
    } finally {
      _downloadTasks.remove(key);
    }
  }

  Future<void> _saveStream(Stream<List<int>> stream, String savePath) async {
    final file = File(savePath);
    final output = file.openWrite();

    try {
      await for (var chunk in stream) {
        output.add(chunk);
      }
    } finally {
      await output.flush();
      await output.close();
    }
  }
}
