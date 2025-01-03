import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text_app/components/base_view/base_view.dart';
import 'package:speech_to_text_app/components/loading/container_with_loading.dart';
import 'package:speech_to_text_app/data/providers_gen/current_user_notifier.dart';
import 'package:speech_to_text_app/data/repositories/auth/auth_local_repository.dart';
import 'package:speech_to_text_app/router/app_router.dart';

import '../../data/models/api/responses/audio_file/audio_file.dart';
import '../../data/models/api/responses/todo/todo.dart';
import '../../data/services/audio_service/audio_service.dart';
import '../main/main_state.dart';
import 'audio_details_state.dart';
import 'audio_details_view_model.dart';

final audioDetailsViewModelProvider = StateNotifierProvider.family<
    AudioDetailsViewModel, AudioDetailsState, TranscriptionEntry>(
  (ref, entry) => AudioDetailsViewModel(
      ref: ref,
      transcriptionEntry: entry,
      authLocalRepository: ref.read(authLocalRepositoryProvider)),
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
  bool _showCompletedTodos = false;
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
    _summaryController.text = widget.entry.summary ?? '';
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.audioFile.title,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          )),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    // final tokenFuture = ref.watch(authLocalRepositoryProvider).getToken();
    final token = ref.read(currentUserNotifierProvider)!.token;
    int currentTabIndex = 0;
    print('words: ${widget.entry.words}');

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
              // Tab Summary
              child: IndexedStack(
                index: audioDetailsState.selectedTabIndex,
                children: [
                  LayoutBuilder(builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom:
                              MediaQuery.of(context).viewInsets.bottom + 16.0,
                        ),
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
                                          Text(
                                              'Todo ${todos.isNotEmpty ? '(${todos.length})' : ''}',
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
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('Show completed todos',
                                              style: TextStyle(fontSize: 12)),
                                          Transform.scale(
                                            scale: 0.55,
                                            child: Switch(
                                              value: _showCompletedTodos,
                                              onChanged: (bool value) {
                                                setState(() {
                                                  _showCompletedTodos = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible: audioDetailsState.isExpanded,
                                        child: Column(
                                          children: [
                                            if (todos.isNotEmpty)
                                              for (final todo
                                                  in todos.where((todo) {
                                                if (_showCompletedTodos) {
                                                  return todo.isCompleted ==
                                                      true;
                                                } else {
                                                  return todo.isCompleted ==
                                                      false;
                                                }
                                              })) ...[
                                                ListTile(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 2.0),
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
                                                          todo.isCompleted ==
                                                                  true
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : null,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                      todo.description ?? ''),
                                                  onTap: () {
                                                    _showEditTodoDialog(
                                                        context, todo);
                                                  },
                                                ),
                                              ]
                                            else
                                              const Text(
                                                  'No to-dos available.'),
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
                                      Visibility(
                                        visible: todos.isNotEmpty &&
                                            audioDetailsState.isExpanded,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 64.0),
                                          child: TextButton(
                                            onPressed: () {
                                              _showAddTodoDialog(context);
                                            },
                                            child: const Row(
                                              children: [
                                                Icon(Icons.add,
                                                    color: Colors.blue,
                                                    size: 20),
                                                Text(
                                                  'Add New To-Do',
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
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
                                              widget.entry.summary ?? '',
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
                                                        _summaryController
                                                            .text);
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
                    );
                  }),
                  RecordingTab(
                    audioFile: widget.audioFile,
                    token: token,
                    transcriptionEntry: widget.entry,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    final _formKey1 = GlobalKey<FormState>(); // Tạo GlobalKey để quản lý form

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New ToDo'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 400,
              ),
              child: Form(
                key: _formKey1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Title'),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 5),
                    const Text('Description'),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: null, // Allow for multiple lines
                      minLines: 3, // Minimum 3 lines
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () async {
                      // Only proceed if the form is valid
                      if (_formKey1.currentState!.validate()) {
                        final title = titleController.text.trim();
                        final description = descriptionController.text.trim();

                        // Call the function to add the To-Do
                        await viewModel.addNewTodo(title, description);
                        Navigator.pop(context); // Close the dialog
                      }
                    },
                    child: const Text('Add'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog without saving
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditTodoDialog(BuildContext context, Todo todo) {
    TextEditingController titleController =
        TextEditingController(text: todo.title);
    TextEditingController descriptionController =
        TextEditingController(text: todo.description);

    final _formKey = GlobalKey<FormState>();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 400,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Title'),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 5),
                    const Text('Description'),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: null,
                      minLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String title =
                            titleController.text.replaceAll('\n', ' ').trim();
                        String description = descriptionController.text
                            .replaceAll('\n', ' ')
                            .trim();

                        await viewModel.updateTodoDetail(
                            todo.id, title, description);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  bool get tapOutsideToDismissKeyBoard => true;

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
    Key? key,
    required this.audioFile,
    required this.token,
    required this.transcriptionEntry,
  }) : super(key: key);

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
  final ScrollController _scrollController = ScrollController();

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
      print("Signed URL: $signedUrl");

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

      // Listen to player state changes
      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });

      // Listen to duration changes
      _audioPlayer.durationStream.listen((duration) {
        if (mounted) {
          setState(() {
            _duration = duration ?? Duration.zero;
          });
        }
      });
    } catch (e) {
      print('Error initializing audio player: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audio: $e')),
        );
      }
    }
  }

  void _updateCurrentWordIndex() {
    final currentTime = _position.inMilliseconds.toDouble() / 1000.0;
    final words = widget.transcriptionEntry.words;
    if (words == null || words.isEmpty) return;

    // Log currentTime để kiểm tra
    print("Current Time: $currentTime");

    // Thêm buffer nhỏ để đảm bảo không bỏ qua từ
    double buffer = 0; // Thử giảm buffer xuống 0.1 giây

    // Tìm kiếm tuyến tính với buffer
    int foundIndex = _currentWordIndex;
    for (int i = 0; i < words.length; i++) {
      if (currentTime >= (words[i].startTime - buffer) &&
          currentTime <= (words[i].endTime + buffer)) {
        foundIndex = i;
        print("Found word at index $foundIndex: ${words[i].word}");
        break;
      }
    }

    if (foundIndex != _currentWordIndex) {
      print("Updating word index from $_currentWordIndex to $foundIndex");
      setState(() {
        _currentWordIndex = foundIndex;
      });
      // Nếu muốn giữ văn bản đứng yên, không gọi _scrollToCurrentWord()
    }
  }

  void _seekForward() {
    final newPosition = _position + Duration(seconds: 5);
    if (newPosition < _duration) {
      _audioPlayer.seek(newPosition);
    } else {
      _audioPlayer.seek(_duration); // Không vượt quá thời gian audio
    }
  }

  void _seekBackward() {
    final newPosition = _position - Duration(seconds: 5);
    if (newPosition > Duration.zero) {
      _audioPlayer.seek(newPosition);
    } else {
      _audioPlayer.seek(Duration.zero); // Không lùi qua 0
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _scrollController.dispose();
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
    return Column(
      children: [
        // Phần nội dung cuộn được
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recording',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Additional Recording Details
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
                const Text(
                  'Transcription',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildHighlightedTranscription(),
                const SizedBox(height: 20),
                // Bạn có thể thêm các nội dung khác ở đây
              ],
            ),
          ),
        ),
        // Phần audio player cố định
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: Colors.white, // Nền trắng hoặc màu bạn muốn
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Audio Player Controls
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.replay_5, size: 36), // Lùi 5 giây
                    onPressed: _seekBackward,
                  ),
                  IconButton(
                    iconSize: 48,
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
                  IconButton(
                    icon: Icon(Icons.forward_5, size: 36), // Tua 5 giây
                    onPressed: _seekForward,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightedTranscription() {
    final words = widget.transcriptionEntry.words;
    if (words == null || words.isEmpty) {
      return Text(
        widget.transcriptionEntry.content ?? '',
        style: const TextStyle(fontSize: 16),
      );
    }

    List<TextSpan> wordSpans = [];
    for (int i = 0; i < words.length; i++) {
      final word = words[i].word;
      final isCurrent = i == _currentWordIndex;

      wordSpans.add(
        TextSpan(
          text: '$word ',
          style: TextStyle(
            color: isCurrent ? Colors.blue : Colors.black,
            backgroundColor: isCurrent ? Colors.yellow : Colors.transparent,
            fontSize: 16,
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
