// lib/screen/home/home_screen.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:speech_to_text_app/components/base_view/base_view.dart';
import 'package:speech_to_text_app/components/loading/container_with_loading.dart';
import 'package:speech_to_text_app/components/loading/loading_view_model.dart';
import 'package:speech_to_text_app/screen/home/home_state.dart';
import 'package:speech_to_text_app/screen/home/home_view_model.dart';

import '../../data/models/api/responses/audio_file/audio_file.dart';
import '../../data/providers/audio_provider.dart';
import '../../data/providers/transcription_provider.dart';
import '../../router/app_router.dart';
import '../main/main_state.dart';

final homeProvider = StateNotifierProvider<HomeViewModel, HomeState>(
  (ref) => HomeViewModel(
    ref: ref,
  ),
);

@RoutePage()
class HomeScreen extends BaseView {
  const HomeScreen({super.key});

  @override
  BaseViewState<HomeScreen, HomeViewModel> createState() => _HomeViewState();
}

class _HomeViewState extends BaseViewState<HomeScreen, HomeViewModel> {
  @override
  Future<void> onInitState() async {
    super.onInitState();
    await Future.delayed(Duration.zero, () async {
      await _onInitData();
    });
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  @override
  Widget buildBody(BuildContext context) {
    final transcriptionHistory = ref.watch(transcriptionProvider);
    final audioFiles = ref.watch(audioFilesProvider);
    print(
        'transcriptionHistoryHome: ${transcriptionHistory.length}, audioFiles: ${audioFiles.length}');

    // // Sắp xếp transcriptionHistory theo createdAt giảm dần
    // List<TranscriptionEntry> sortedTranscriptions =
    //     List.from(transcriptionHistory);
    // sortedTranscriptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Nhóm các transcription theo ngày
    Map<String, List<TranscriptionEntry>> groupedTranscriptions = {};
    for (var entry in transcriptionHistory) {
      String dateKey = _formatDate(entry.createdAt);
      if (groupedTranscriptions.containsKey(dateKey)) {
        groupedTranscriptions[dateKey]!.add(entry);
      } else {
        groupedTranscriptions[dateKey] = [entry];
      }
    }

    // Chuyển đổi groupedTranscriptions thành một danh sách kết hợp giữa headers và items
    List<dynamic> combinedList = [];
    groupedTranscriptions.forEach((date, entries) {
      combinedList.add(date); // Thêm tiêu đề ngày
      combinedList.addAll(entries); // Thêm các transcription của ngày đó
    });

    return ContainerWithLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UpgradeWidget(),
              const SizedBox(height: 24.0),
              const SearchBarWidget(),
              const SizedBox(height: 24.0),
              combinedList.isNotEmpty
                  ? ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: combinedList.length,
                      itemBuilder: (context, index) {
                        final item = combinedList[index];
                        if (item is String) {
                          // Đây là tiêu đề ngày
                          return ListSectionHeader(title: item);
                        } else if (item is TranscriptionEntry) {
                          final entry = item;
                          final audioFile = audioFiles.firstWhere(
                            (audio) => audio.id == entry.audioFileId,
                            orElse: () => AudioFile(
                              id: 'unknown',
                              title: 'Processing...',
                              fileUrl: '',
                              uploadedAt: DateTime.now(),
                              transcriptionId: null,
                              isProcessing: false,
                            ),
                          );

                          print(
                              'Displaying entry: ${entry.id} - ${entry.content} - isProcessing: ${entry.isProcessing}');

                          return GestureDetector(
                            onTap: () {
                              if (!entry.isProcessing && !entry.isError) {
                                context.router.push(AudioDetailsRoute(
                                  entry: entry,
                                  audioFile: audioFile,
                                ));
                              }
                            },
                            child: RecordingTile(
                              entry: entry,
                              audioFile: audioFile,
                            ),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    )
                  : const Center(
                      child: Text('No recordings yet'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  bool get tapOutsideToDismissKeyBoard => true;

  @override
  bool get ignoreSafeAreaBottom => false;

  @override
  HomeViewModel get viewModel => ref.read(homeProvider.notifier);

  @override
  String get screenName => HomeRoute.name;

  HomeState get state => ref.watch(homeProvider);

  LoadingStateViewModel get loading => ref.read(loadingStateProvider.notifier);

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

class UpgradeWidget extends StatelessWidget {
  const UpgradeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.upgrade, color: Colors.purple),
          const SizedBox(width: 16.0),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upgrade now',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Don't miss anything important",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.purple),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
    );
  }
}

class RecordingTile extends ConsumerWidget {
  final TranscriptionEntry entry;
  final AudioFile audioFile;

  const RecordingTile({
    super.key,
    required this.entry,
    required this.audioFile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(homeProvider.notifier);
    print(
        'RecordingTile - Building for transcription ID: ${entry.id}, isProcessing: ${entry.isProcessing}, audioFileId: ${entry.audioFileId}');
    return SizedBox(
      height: 180,
      child: Slidable(
        key: Key(entry.id),
        enabled: !entry.isProcessing,
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.5,
          children: [
            CustomSlidableAction(
              onPressed: (context) async {
                final newTitle = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      final controller =
                          TextEditingController(text: audioFile.title);
                      return AlertDialog(
                        title: const Text('Update title'),
                        content: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: 'Enter new title',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(controller.text),
                            child: const Text('Update'),
                          ),
                        ],
                      );
                    });
                if (newTitle != null && newTitle.trim().isNotEmpty) {
                  await viewModel.updateAudioFileTitle(
                      audioFile, newTitle.trim());
                }
              },
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                height: 164,
                width: MediaQuery.of(context).size.width / 2,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, color: Colors.white),
                    Text('Edit title',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
            CustomSlidableAction(
              onPressed: (context) async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Transcription'),
                    content: const Text(
                        'Do you want to delete this recording? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await viewModel.deleteAudioFile(audioFile);
                }
              },
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                height: 164,
                width: MediaQuery.of(context).size.width / 2,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, color: Colors.white),
                    Text('Delete',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: entry.isError
                ? Colors.red.shade50
                : (entry.isProcessing ? Colors.grey.shade200 : Colors.white),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                audioFile.title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: entry.isError
                      ? Colors.red
                      : (entry.isProcessing ? Colors.grey : Colors.black),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (entry.isProcessing) ...[
                const SizedBox(height: 8.0),
                const LinearProgressIndicator(),
              ] else if (entry.isError) ...[
                const SizedBox(height: 4.0),
                Text(
                  entry.content ?? 'An error occurred.',
                  style: const TextStyle(fontSize: 14.0, color: Colors.red),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ] else ...[
                const SizedBox(height: 4.0),
                Flexible(
                  child: Text(
                    entry.content ?? 'No transcription available.',
                    style:
                        const TextStyle(fontSize: 14.0, color: Colors.black87),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 4.0),
              Text(
                entry.createdAt.toLocal().toString().split(' ')[0],
                style: const TextStyle(fontSize: 12.0, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListSectionHeader extends StatelessWidget {
  final String title;

  const ListSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
