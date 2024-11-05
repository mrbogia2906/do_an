import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudioDownloadManager {
  final YoutubeExplode _ytExplode = YoutubeExplode();
  final Map<String, Future<void>> _downloadTasks = {};

  Future<void> downloadAudioInBackground(String key, String audioTitle) async {
    final cacheDir = await getTemporaryDirectory();
    final tempSavePath = '${cacheDir.path}/${audioTitle}_temp.mp3';
    final finalSavePath = '${cacheDir.path}/$audioTitle.mp3';

    final file = File(finalSavePath);
    if (!await file.exists()) {
      if (_downloadTasks.containsKey(key)) {
        return;
      }

      _downloadTasks[key] =
          _download(key, audioTitle, tempSavePath, finalSavePath);
    }
  }

  Future<void> _download(
    String key,
    String audioTitle,
    String tempSavePath,
    String finalSavePath,
  ) async {
    try {
      var video =
          await _ytExplode.videos.get('https://youtube.com/watch?v=$key');
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
    } finally {
      await _downloadTasks.remove(key);
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
