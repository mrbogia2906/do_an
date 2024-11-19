import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text_app/components/base_view/base_view.dart';
import 'package:speech_to_text_app/data/repositories/auth/auth_local_repository.dart';

import '../../data/models/api/responses/audio_file/audio_file.dart';
import '../../data/services/audio_service/audio_service.dart';
import '../main/main_state.dart';

@RoutePage()
class AudioDetailsScreen extends ConsumerWidget {
  final TranscriptionEntry entry;
  final AudioFile audioFile;

  const AudioDetailsScreen({
    super.key,
    required this.entry,
    required this.audioFile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenFuture = ref.watch(authLocalRepositoryProvider).getToken();
    bool isExpanded = false;
    int selectedTabIndex = 0;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Audio Details'),
          centerTitle: true,
          // bottom: TabBar(
          //   tabs: [
          //     Tab(text: 'Summary'),
          //     Tab(text: 'Recording'),
          //   ],
          // ),
        ),
        body: Consumer(
          builder: (context, ref, child) {
            return Column(
              children: [
                TabBar(
                  onTap: (index) {
                    selectedTabIndex = index; // Cập nhật tab hiện tại
                    (context as Element)
                        .markNeedsBuild(); // Yêu cầu xây dựng lại
                  },
                  tabs: const [
                    Tab(text: 'Summary'),
                    Tab(text: 'Recording'),
                  ],
                ),
                Expanded(
                  child: IndexedStack(
                    index: selectedTabIndex,
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // To-do Section
                              Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('To-do',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          IconButton(
                                            icon: Icon(
                                              isExpanded
                                                  ? Icons.expand_less
                                                  : Icons.expand_more,
                                              color: Colors.black,
                                            ),
                                            onPressed: () {
                                              // Quản lý trạng thái mở rộng
                                              isExpanded = !isExpanded;
                                              // Cập nhật state nếu cần
                                              (context as Element)
                                                  .markNeedsBuild(); // Yêu cầu xây dựng lại
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Visibility(
                                        visible: isExpanded,
                                        child: ElevatedButton.icon(
                                          onPressed: () {},
                                          icon: const Icon(Icons.flash_on,
                                              color: Color(0xFF8E4AD7)),
                                          label: const Text(
                                            'Create todo list',
                                            style: TextStyle(
                                                color: Color(0xFF8E4AD7)),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            side: const BorderSide(
                                                color: Color(0xFF8E4AD7)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            minimumSize:
                                                const Size.fromHeight(50),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Summary Content
                              Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Summary',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Icon(Icons.edit,
                                              color: Colors.black54),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Summary of the Discussion',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        entry.content ?? '',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      FutureBuilder<String?>(
                        future: tokenFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return const Center(
                                child: Text('Token not available'));
                          } else {
                            return RecordingTab(
                                audioFile: audioFile, token: snapshot.data!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Recording Tab Widget
class RecordingTab extends StatefulWidget {
  final AudioFile audioFile;
  final String token;

  const RecordingTab({
    super.key,
    required this.audioFile,
    required this.token,
  });

  @override
  _RecordingTabState createState() => _RecordingTabState();
}

class _RecordingTabState extends State<RecordingTab> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      String signedUrl =
          await _audioService.getSignedUrl(widget.audioFile.id, widget.token);
      print("Signed URL: $signedUrl"); // Để debug

      // Load audio từ Signed URL
      await _audioPlayer.setUrl(signedUrl);
      _duration = _audioPlayer.duration ?? Duration.zero;

      // Listen to audio position changes
      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });
    } catch (e) {
      print('Error initializing audio player: $e');
      // Hiển thị thông báo lỗi nếu cần
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audio: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recording',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Audio Player Controls
          Column(
            children: [
              Slider(
                min: 0,
                max: _duration.inMilliseconds.toDouble(),
                value: _position.inMilliseconds
                    .toDouble()
                    .clamp(0.0, _duration.inMilliseconds.toDouble()),
                onChanged: (value) {
                  _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position)),
                  Text(_formatDuration(_duration)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 64,
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      color: Colors.purple,
                    ),
                    onPressed: () {
                      if (_isPlaying) {
                        _audioPlayer.pause();
                      } else {
                        _audioPlayer.play();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Additional Recording Details (nếu cần)
          const Text(
            'Audio File Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Title: ${widget.audioFile.title}',
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            'Uploaded At: ${widget.audioFile.uploadedAt.toLocal().toString().split(' ')[0]}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
