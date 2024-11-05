import 'package:flutter/material.dart';
import 'package:speech_to_text_app/trans.dart';

class TranscriptionHistoryScreen extends StatelessWidget {
  final List<TranscriptionEntry> history;

  TranscriptionHistoryScreen({required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transcription History')),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final entry = history[index];
          return ListTile(
            title: Text(entry.title),
            subtitle: Text(entry.content.length > 50
                ? '${entry.content.substring(0, 50)}...'
                : entry.content),
            trailing: Text(entry.timestamp.toString().split(' ')[0]),
            onTap: () {
              // Navigate to detail page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TranscriptionDetailScreen(entry: entry),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TranscriptionDetailScreen extends StatelessWidget {
  final TranscriptionEntry entry;

  TranscriptionDetailScreen({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(entry.title)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${entry.timestamp.toString().split(' ')[0]}'),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(entry.content),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
