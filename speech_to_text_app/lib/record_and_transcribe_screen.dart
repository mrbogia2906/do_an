import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text_app/trans.dart';
import 'package:speech_to_text_app/trans_detail_screen.dart';

class RecordAndTranscribeScreen extends StatefulWidget {
  @override
  _RecordAndTranscribeScreenState createState() =>
      _RecordAndTranscribeScreenState();
}

class _RecordAndTranscribeScreenState extends State<RecordAndTranscribeScreen> {
  List<TranscriptionEntry> _transcriptionHistory = [];
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _audioPath;
  String _transcriptionText = ''; // Variable to store the transcription text
  bool _isLoading = false; // Variable to indicate loading state

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _recorder!.openRecorder();
    _loadTranscriptionHistory();
  }

  Future<void> _loadTranscriptionHistory() async {
    // Load history from local storage (e.g., SharedPreferences)
    // For now, we'll just initialize with some dummy data
    setState(() {
      _transcriptionHistory = [
        TranscriptionEntry(
          title: "Sample Transcription",
          content: "This is a sample transcription.",
          timestamp: DateTime.now(),
        ),
      ];
    });
  }

  Future<void> _saveTranscription(String title, String content) async {
    final entry = TranscriptionEntry(
      title: title,
      content: content,
      timestamp: DateTime.now(),
    );
    setState(() {
      _transcriptionHistory.insert(
          0, entry); // Add to the beginning of the list
    });
    // Save to local storage (e.g., SharedPreferences)
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/audio';
    await _recorder!.startRecorder(toFile: path);
    setState(() {
      _isRecording = true;
      _audioPath = path;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      setState(() {
        _audioPath = result.files.single.path;
      });
      print('Audio file selected: $_audioPath');
    } else {
      print('No file selected');
    }
  }

  Future<void> _sendToTranscription(String endpoint) async {
    if (_audioPath == null) return;

    setState(() {
      _isLoading = true;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.10.180.39:3000/$endpoint'),
    );
    request.files.add(await http.MultipartFile.fromPath('audio', _audioPath!));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await http.Response.fromStream(response);
      var data = json.decode(responseBody.body);

      // Update the state to display the transcription text
      setState(() {
        _transcriptionText = data['transcription'];
      });

      await _saveTranscription("New Transcription", _transcriptionText);
    } else {
      print('Error: Unable to transcribe audio');
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Expose the transcription history
  List<TranscriptionEntry> get transcriptionHistory => _transcriptionHistory;

  @override
  void dispose() {
    _recorder!.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Record and Transcribe')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TranscriptionHistoryScreen(
                        history: _transcriptionHistory),
                  ),
                );
              },
              child: Text('View History'),
            ),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            ElevatedButton(
              onPressed: _pickAudioFile,
              child: Text('Select Audio File'),
            ),
            ElevatedButton(
              onPressed: () => _sendToTranscription('transcribe'),
              child: Text('Send for Google Speech-to-Text'),
            ),
            ElevatedButton(
              onPressed: () => _sendToTranscription('gemini-transcribe'),
              child: Text('Send for Gemini AI Transcription'),
            ),
            SizedBox(height: 20),
            // Display CircularProgressIndicator when loading
            if (_isLoading) CircularProgressIndicator(),
            SizedBox(height: 20),
            // Display the transcription text in a scrollable view
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Text(
                    _transcriptionText.isNotEmpty
                        ? _transcriptionText
                        : 'Transcription will appear here',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
