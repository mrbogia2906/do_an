// audio_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../screen/main/main_state.dart';
import '../../../utilities/constants/server_constants.dart';
import '../../models/api/responses/audio_file/audio_file.dart';

class AudioService {
  final String baseUrl = "${ServerConstant.serverURL}/api";

  // Hàm upload audio
  Future<AudioFile> uploadAudio(
      File audioFile, String title, String token) async {
    final uri = Uri.parse('$baseUrl/upload-audio');
    final request = http.MultipartRequest('POST', uri)
      ..headers['x-auth-token'] = token
      ..fields['title'] = title
      ..files.add(await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
        filename: audioFile.uri.pathSegments.last, // Sử dụng tên tệp gốc
      ));

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 201) {
      final responseBody = await streamedResponse.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);
      return AudioFile.fromJson(jsonResponse);
    } else {
      final responseBody = await streamedResponse.stream.bytesToString();
      throw Exception(
          'Failed to upload audio: ${streamedResponse.statusCode} - $responseBody');
    }
  }

  // Hàm tạo Signed URL
  Future<String> getSignedUrl(String audioId, String token) async {
    final uri = Uri.parse('$baseUrl/generate-signed-url/$audioId');
    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "x-auth-token": token,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['signed_url'];
    } else {
      final responseBody = response.body;
      throw Exception(
          'Failed to get signed URL: ${response.statusCode} - $responseBody');
    }
  }

  // Hàm lấy danh sách audio files
  Future<List<AudioFile>> getAudioFiles(String token) async {
    var uri = Uri.parse("$baseUrl/audio-files");

    var response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "x-auth-token": token,
      },
    );

    if (response.statusCode == 200) {
      // Sử dụng utf8.decode để đảm bảo dữ liệu được giải mã đúng cách
      final decodedBody = json.decode(utf8.decode(response.bodyBytes));
      return (decodedBody as List)
          .map<AudioFile>((json) => AudioFile.fromJson(json))
          .toList();
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to fetch audio files');
    }
  }

  // Hàm lấy transcription
  Future<TranscriptionEntry> getTranscription(
      String transcriptionId, String token) async {
    var uri = Uri.parse("$baseUrl/transcriptions/$transcriptionId");

    var response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "x-auth-token": token,
      },
    );

    if (response.statusCode == 200) {
      // Sử dụng utf8.decode để đảm bảo dữ liệu được giải mã đúng cách
      final decodedBody = json.decode(utf8.decode(response.bodyBytes));
      print(
          'Fetched transcription content: ${decodedBody['content']}'); // Kiểm tra log
      return TranscriptionEntry.fromJson(decodedBody);
    } else {
      throw Exception("Failed to fetch transcription");
    }
  }
}
