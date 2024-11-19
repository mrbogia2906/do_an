// lib/screen/home/home_screen.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:speech_to_text_app/components/base_view/base_view.dart';
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

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UpgradeWidget(),
              const SizedBox(height: 24.0),
              const SearchBarWidget(),
              const SizedBox(height: 24.0),
              transcriptionHistory.isNotEmpty
                  ? ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: transcriptionHistory.length,
                      itemBuilder: (context, index) {
                        final entry = transcriptionHistory[index];
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
                                audioFile: audioFile, // Truyền thêm AudioFile
                              ));
                            }
                          },
                          child: RecordingTile(
                            entry: entry,
                            audioFile: audioFile, // Truyền thêm AudioFile
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text('No recordings yet'),
                    ),
              // Bạn có thể thêm thêm các widget khác ở đây nếu cần
            ],
          ),
        ),
      ),
    );
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
    return Slidable(
      key: Key(entry.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) async {
              // Hiển thị hộp thoại xác nhận trước khi xoá
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Xoá AudioFile'),
                  content: Text(
                      'Bạn có chắc chắn muốn xoá AudioFile này và bản transcription liên quan?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Không'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Có'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                // Gọi phương thức xoá AudioFile và Transcription
                await viewModel.deleteAudioFile(audioFile);
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(12.0),
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
          children: [
            Text(
              audioFile.title, // Lấy title từ AudioFile
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: entry.isError
                    ? Colors.red
                    : (entry.isProcessing ? Colors.grey : Colors.black),
              ),
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
              Text(
                entry.content ?? 'No transcription available.',
                style: const TextStyle(fontSize: 14.0, color: Colors.black87),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
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
    );
  }
}

class ListSectionHeader extends StatelessWidget {
  final String title;

  const ListSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }
}
