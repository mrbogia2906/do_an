import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/screen/main/main_state.dart';
import 'package:speech_to_text_app/screen/main/main_view_model.dart';

import '../../components/base_view/base_view.dart';
import '../../router/app_router.dart';
import 'components/bottom_tab_bar.dart';

final mainProvider = StateNotifierProvider<MainViewModel, MainState>(
  (ref) => MainViewModel(ref: ref),
);

@RoutePage()
class MainScreen extends BaseView {
  const MainScreen({
    super.key,
  });

  @override
  BaseViewState<MainScreen, MainViewModel> createState() => _MainViewState();
}

class _MainViewState extends BaseViewState<MainScreen, MainViewModel> {
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  @override
  bool get ignoreSafeAreaBottom => true;

  @override
  Widget buildBody(BuildContext context) {
    print('audio main: ${state.audioPath}, mainIsloading1: ${state.isLoading}');
    return AutoTabsScaffold(
      routes: const [
        HomeTabRoute(),
        TodoTabRoute(),
        UpgradeTabRoute(),
        AccountTabRoute(),
      ],
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        onPressed: () {
          print(
              'audio main: ${state.audioPath}, mainIsloading2: ${state.isLoading}');

          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (BuildContext context) {
              return _buildWidget(context, ref);
            },
          );
        },
        child: const Icon(Icons.mic),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBuilder: (context, tabsRouter) {
        return BottomTabBar(tabsRouter: tabsRouter);
      },
    );
  }

  Widget _buildWidget(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(mainProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose recording',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (state.recordingState == RecordingState.idle) ...[
            ElevatedButton.icon(
              onPressed: () {
                viewModel.startRecording();
              },
              icon: const Icon(Icons.mic, color: Colors.white),
              label: const Text('Record'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _OptionButton(
                  icon: Icons.upload,
                  label: 'Upload file',
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (BuildContext context) {
                        return _buildUploadFileSheet(context, ref);
                      },
                    );
                  },
                ),
                _OptionButton(
                  icon: Icons.link,
                  label: 'YouTube Link',
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (BuildContext context) {
                        return _buildYouTubeLinkSheet(context);
                      },
                    );
                  },
                ),
                _OptionButton(
                  icon: Icons.video_call,
                  label: 'Online Meeting',
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (BuildContext context) {
                        return _buildOnlineMeetingSheet(context);
                      },
                    );
                  },
                ),
              ],
            ),
          ] else if (state.recordingState == RecordingState.recording) ...[
            const Text('Recording...', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              height: 100,
              color: Colors.grey[200],
              child: const Center(
                child: Text('Waveform here'),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    viewModel.pauseRecording();
                  },
                  child: const Text('Pause'),
                ),
                TextButton(
                  onPressed: () {
                    viewModel.stopRecording();
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ] else if (state.recordingState == RecordingState.paused) ...[
            const Text('Paused', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              height: 100,
              color: Colors.grey[200],
              child: const Center(
                child: Text('Waveform here'),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    viewModel.resumeRecording();
                  },
                  child: const Text('Continue'),
                ),
                TextButton(
                  onPressed: () {
                    viewModel.stopRecording();
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadFileSheet(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upload audio file',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Choose language',
              border: OutlineInputBorder(),
            ),
            items: ['Vietnamese', 'English'].map((String language) {
              return DropdownMenuItem<String>(
                value: language,
                child: Text(language),
              );
            }).toList(),
            onChanged: (String? value) {},
          ),
          const SizedBox(height: 20),
          const Text(
            'Selecting the appropriate language helps improve the quality of the recording',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              viewModel.pickAudioFile2(context).then((_) {
                print('transcriptionMain: ${state.transcriptionHistory}');
              });
            },
            icon: const Icon(Icons.upload, color: Colors.white),
            label: const Text('Choose file to upload'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouTubeLinkSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transcribe audio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Choose language',
              border: OutlineInputBorder(),
            ),
            items: ['Vietnamese', 'English'].map((String language) {
              return DropdownMenuItem<String>(
                value: language,
                child: Text(language),
              );
            }).toList(),
            onChanged: (String? value) {},
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Enter YouTube link',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Add YouTube transcription functionality here
            },
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: const Text('Start'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineMeetingSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Schedule Online Meeting',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          // Additional content for online meeting scheduling can be added here
          // This can include date and time pickers, meeting link fields, etc.
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.purple, size: 30),
          onPressed: onTap,
        ),
        Text(label, style: const TextStyle(color: Colors.purple)),
      ],
    );
  }

  @override
  String get screenName => MainRoute.name;

  MainState get state => ref.watch(mainProvider);

  @override
  MainViewModel get viewModel => ref.read(mainProvider.notifier);
}

class _RecordingOptions extends ConsumerWidget {
  const _RecordingOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(mainProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose recording',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (recordingState.recordingState == RecordingState.idle) ...[
            ElevatedButton.icon(
              onPressed: () {
                ref.read(mainProvider.notifier).startRecording();
              },
              icon: const Icon(Icons.mic, color: Colors.white),
              label: const Text('Record'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _OptionButton(
                  icon: Icons.upload,
                  label: 'Upload file',
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (BuildContext context) {
                        return const _UploadFileSheet();
                      },
                    );
                  },
                ),
                _OptionButton(
                  icon: Icons.link,
                  label: 'YouTube Link',
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (BuildContext context) {
                        return const _YouTubeLinkSheet();
                      },
                    );
                  },
                ),
                _OptionButton(
                  icon: Icons.video_call,
                  label: 'Online Meeting',
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (BuildContext context) {
                        return const _OnlineMeetingSheet();
                      },
                    );
                  },
                ),
              ],
            ),
          ] else if (recordingState.recordingState ==
              RecordingState.recording) ...[
            const Text('Recording...', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            // Placeholder for a waveform visual
            Container(
              height: 100,
              color: Colors.grey[200],
              child: const Center(
                child: Text('Waveform here'),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    ref.read(mainProvider.notifier).pauseRecording();
                  },
                  child: const Text('Pause'),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(mainProvider.notifier).stopRecording();
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ] else if (recordingState.recordingState ==
              RecordingState.paused) ...[
            const Text('Paused', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            // Placeholder for a waveform visual
            Container(
              height: 100,
              color: Colors.grey[200],
              child: const Center(
                child: Text('Waveform here'),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    ref.read(mainProvider.notifier).resumeRecording();
                  },
                  child: const Text('Continue'),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(mainProvider.notifier).stopRecording();
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Upload File Bottom Sheet
class _UploadFileSheet extends ConsumerWidget {
  const _UploadFileSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upload audio file',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Choose language',
              border: OutlineInputBorder(),
            ),
            items: ['Vietnamese', 'English'].map((String language) {
              return DropdownMenuItem<String>(
                value: language,
                child: Text(language),
              );
            }).toList(),
            onChanged: (String? value) {},
          ),
          const SizedBox(height: 20),
          const Text(
            'Selecting the appropriate language helps improve the quality of the recording',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(mainProvider.notifier).pickAudioFile2(context);
            },
            icon: const Icon(Icons.upload, color: Colors.white),
            label: const Text('Choose file to upload'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// YouTube Link Bottom Sheet
class _YouTubeLinkSheet extends StatelessWidget {
  const _YouTubeLinkSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transcribe audio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Choose language',
              border: OutlineInputBorder(),
            ),
            items: ['Vietnamese', 'English'].map((String language) {
              return DropdownMenuItem<String>(
                value: language,
                child: Text(language),
              );
            }).toList(),
            onChanged: (String? value) {},
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Enter YouTube link',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Add YouTube transcription functionality here
            },
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: const Text('Start'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Online Meeting Bottom Sheet
class _OnlineMeetingSheet extends StatelessWidget {
  const _OnlineMeetingSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Schedule Online Meeting',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          // Additional content for online meeting scheduling can be added here
          // This can include date and time pickers, meeting link fields, etc.
        ],
      ),
    );
  }
}

// Helper widget for buttons in the recording options sheet
class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.purple, size: 30),
          onPressed: onTap,
        ),
        Text(label, style: const TextStyle(color: Colors.purple)),
      ],
    );
  }
}
