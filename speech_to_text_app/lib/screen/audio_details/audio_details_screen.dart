import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text_app/components/base_view/base_view.dart';
import 'package:speech_to_text_app/components/loading/container_with_loading.dart';
import 'package:speech_to_text_app/data/repositories/auth/auth_local_repository.dart';
import 'package:speech_to_text_app/router/app_router.dart';

import '../../data/models/api/responses/audio_file/audio_file.dart';
import '../../data/services/audio_service/audio_service.dart';
import '../main/main_state.dart';
import 'audio_details_state.dart';
import 'audio_details_view_model.dart';

final audioDetailsViewModelProvider = StateNotifierProvider.family<
    AudioDetailsViewModel, AudioDetailsState, TranscriptionEntry>(
  (ref, entry) => AudioDetailsViewModel(ref: ref, transcriptionEntry: entry),
);

@RoutePage()
class AudioDetailsScreen extends BaseView {
  final TranscriptionEntry entry;
  final AudioFile audioFile;

  const AudioDetailsScreen({
    super.key,
    required this.entry,
    required this.audioFile,
  });

  @override
  BaseViewState<AudioDetailsScreen, AudioDetailsViewModel> createState() =>
      _AudioDetailsScreenState();
}

class _AudioDetailsScreenState
    extends BaseViewState<AudioDetailsScreen, AudioDetailsViewModel> {
  TextEditingController _summaryController = TextEditingController();
  bool _isEditingSummary = false;
  bool _isUpdating = false;
  @override
  AudioDetailsViewModel get viewModel =>
      ref.read(audioDetailsViewModelProvider(widget.entry).notifier);

  @override
  Future<void> onInitState() async {
    super.onInitState();
    await Future.delayed(Duration.zero, () async {
      await _onInitData();
    });
    _summaryController.text = widget.entry.content ?? '';
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Audio Details'),
      centerTitle: true,
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final tokenFuture = ref.watch(authLocalRepositoryProvider).getToken();
    int currentTabIndex = 0;

    // Lấy trạng thái hiện tại từ ViewModel
    final audioDetailsState =
        ref.watch(audioDetailsViewModelProvider(widget.entry));
    final todos = ref.watch(audioDetailsViewModelProvider(widget.entry)).todos;
    print('Todos: $todos');

    print(
        'Words list: ${widget.entry.words}, transcriptionId: ${widget.entry.id}, audioFileId: ${widget.entry.audioFileId}');

    return ContainerWithLoading(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              onTap: (index) {
                viewModel.setSelectedTabIndex(index);
              },
              tabs: const [
                Tab(text: 'Summary'),
                Tab(text: 'Recording'),
              ],
            ),
            Expanded(
              child: IndexedStack(
                index: audioDetailsState.selectedTabIndex,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          'To-do ${todos.isNotEmpty ? '(${todos.length})' : ''}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: Icon(
                                          audioDetailsState.isExpanded
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          color: Colors.black,
                                        ),
                                        onPressed: () {
                                          viewModel.toggleExpanded();
                                        },
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible: audioDetailsState.isExpanded,
                                    child: Column(
                                      children: [
                                        if (todos.isNotEmpty)
                                          for (final todo in todos) ...[
                                            ListTile(
                                              leading: Checkbox(
                                                value: todo.isCompleted,
                                                onChanged: (bool? value) {
                                                  viewModel
                                                      .toggleTodoCompletion(
                                                          todo.id,
                                                          value ?? false);
                                                },
                                              ),
                                              title: Text(
                                                todo.title,
                                                style: TextStyle(
                                                  decoration:
                                                      todo.isCompleted == true
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : null,
                                                ),
                                              ),
                                              subtitle:
                                                  Text(todo.description ?? ''),
                                            ),
                                          ]
                                        else
                                          const Text('No to-dos available.'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Visibility(
                                    visible: audioDetailsState.isExpanded &&
                                        audioDetailsState
                                            .isVisibleCreateTodoButton,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        onLoading(() async {
                                          await viewModel.generateTodos();
                                        });
                                        // viewModel.generateTodos();
                                      },
                                      icon: const Icon(Icons.flash_on,
                                          color: Color(0xFF8E4AD7)),
                                      label: const Text(
                                        'Create todo list with AI',
                                        style:
                                            TextStyle(color: Color(0xFF8E4AD7)),
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
                                        minimumSize: const Size.fromHeight(50),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Summary',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.black54),
                                        onPressed: _isEditingSummary
                                            ? null
                                            : () {
                                                setState(() {
                                                  _isEditingSummary =
                                                      !_isEditingSummary;
                                                });
                                              },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Nếu đang ở chế độ chỉnh sửa, hiển thị TextField, ngược lại hiển thị Text
                                  _isEditingSummary
                                      ? TextField(
                                          controller: _summaryController,
                                          maxLines: null,
                                          minLines: 5,
                                          decoration: const InputDecoration(
                                            hintText: "Edit summary here",
                                            border: OutlineInputBorder(),
                                          ),
                                        )
                                      : Text(
                                          widget.entry.content ?? '',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87),
                                        ),
                                  const SizedBox(height: 10),
                                  // Các nút xác nhận/hủy nếu đang chỉnh sửa
                                  _isEditingSummary
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isEditingSummary = false;
                                                });
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // Lưu thay đổi
                                                viewModel.updateSummary(
                                                    _summaryController.text);
                                                setState(() {
                                                  _isEditingSummary = false;
                                                });
                                              },
                                              child: const Text('Confirm'),
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder<String?>(
                    future: tokenFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(child: Text('Token not available'));
                      } else {
                        return RecordingTab(
                          audioFile: widget.audioFile,
                          token: snapshot.data!,
                          transcriptionEntry: widget.entry,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  String get screenName => AudioDetailsRoute.name;

  Future<void> _onInitData() async {
    Object? error;

    await loading.whileLoading(context, () async {
      try {
        await viewModel.initData();
      } catch (e) {
        error = e;
      }
    });

    if (error != null) {
      handleError(error!);
    }
  }
}

// Recording Tab Widget
class RecordingTab extends StatefulWidget {
  final AudioFile audioFile;
  final String token;
  final TranscriptionEntry transcriptionEntry;

  const RecordingTab({
    super.key,
    required this.audioFile,
    required this.token,
    required this.transcriptionEntry,
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
  int _currentWordIndex = 0;

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
            _updateCurrentWordIndex();
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

  void _updateCurrentWordIndex() {
    final currentTime = _position.inMilliseconds;
    final words = widget.transcriptionEntry.words;
    if (words == null || words.isEmpty) return;
    for (int i = 0; i < words.length; i++) {
      final wordStart = (words[i].startTime * 1000).toInt();
      final wordEnd = (words[i].endTime * 1000).toInt();
      if (currentTime >= wordStart && currentTime <= wordEnd) {
        _currentWordIndex = i;
        break;
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
    return SingleChildScrollView(
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
          const SizedBox(height: 20),
          Text(
            'Transcription',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildHighlightedTranscription(),
        ],
      ),
    );
  }

  Widget _buildHighlightedTranscription() {
    final words = widget.transcriptionEntry.words;
    List<TextSpan> wordSpans = [];
    if (words == null || words.isEmpty) {
      // Fallback to displaying plain transcription text
      return Text(
        widget.transcriptionEntry.content ?? '',
        style: const TextStyle(fontSize: 16),
      );
    }
    print('words.length = ${words.length}');
    for (int i = 0; i < words.length; i++) {
      final isCurrentWord = i == _currentWordIndex;
      wordSpans.add(
        TextSpan(
          text: '${words[i].word} ',
          style: TextStyle(
            color: isCurrentWord ? Colors.blue : Colors.black,
            backgroundColor: isCurrentWord ? Colors.yellow : Colors.transparent,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16),
        children: wordSpans,
      ),
    );
  }
}
