// lib/screen/main/main_screen.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/screen/main/main_state.dart';
import 'package:speech_to_text_app/screen/main/main_view_model.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

import '../../components/base_view/base_view.dart';
import '../../data/view_model/auth_viewmodel.dart';
import '../../router/app_router.dart';
import 'components/bottom_tab_bar.dart';

final mainProvider = StateNotifierProvider<MainViewModel, MainState>(
  (ref) => MainViewModel(
    ref: ref,
    authViewModel: ref.read(authViewModelProvider.notifier),
  ),
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
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    // print('audio main: ${state.audioPath}, mainIsloading1: ${state.isLoading}');
    return AutoTabsScaffold(
      routes: const [
        HomeTabRoute(),
        TodoTabRoute(),
        UpgradeTabRoute(),
        AccountTabRoute(),
      ],
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        onPressed: () {
          // print(
          //     'audio main: ${state.audioPath}, mainIsloading2: ${state.isLoading}');

          showModalBottomSheet(
            isScrollControlled: true,
            isDismissible: false,
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (BuildContext context) {
              return _buildWidget(context, ref);
            },
          );
        },
        backgroundColor: Colors.blue,
        child: Container(
          width: 56.0,
          height: 56.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Colors.purple,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.mic,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBuilder: (context, tabsRouter) {
        return BottomTabBar(tabsRouter: tabsRouter);
      },
    );
  }

  Widget _buildWidget(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final recordingState = ref.watch(mainProvider);
        final viewModel = ref.read(mainProvider.notifier);

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tiêu đề và nút đóng
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
              // Hiển thị các trạng thái ghi âm
              if (recordingState.recordingState == RecordingState.idle) ...[
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      viewModel.startRecording();
                    },
                    icon: const Icon(Icons.mic, color: Colors.white),
                    label: const Text('Record',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.transparent, // Đặt màu nền thành trong suốt
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                      onTap: () async {
                        Navigator.pop(context);
                        await showModalBottomSheet(
                          isDismissible: false,
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
                          isDismissible: false,
                          isScrollControlled: true,
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (BuildContext context) {
                            return YouTubeLinkSheet(viewModel: viewModel);
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
                // Waveform Widget
                AudioWaveforms(
                  enableGesture: false, // Disable gestures if not needed
                  size: const Size(double.infinity, 100),
                  recorderController: viewModel.recorderController,
                  waveStyle: const WaveStyle(
                    waveColor: Colors.blue,
                    extendWaveform: true,
                    showMiddleLine: false,
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
                        viewModel.stopRecording(context);
                        // Navigator.pop(context);
                        AutoRouter.of(context).pop();
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ] else if (recordingState.recordingState ==
                  RecordingState.paused) ...[
                const Text('Paused', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                // Waveform Widget (can display a static waveform or the same as recording)
                AudioWaveforms(
                  enableGesture: false,
                  size: const Size(double.infinity, 100),
                  recorderController: viewModel.recorderController,
                  waveStyle: const WaveStyle(
                    waveColor: Colors.blue,
                    extendWaveform: true,
                    showMiddleLine: false,
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
                        viewModel.stopRecording(context);
                        // Navigator.pop(context);
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ],
              // if (recordingState.audioPath != null) ...[
              //   const SizedBox(height: 20),
              //   Text('File ghi âm: ${recordingState.audioPath}'),
              //   // Bạn có thể thêm nút để phát lại hoặc tải lên file âm thanh ở đây
              // ],
            ],
          ),
        );
      },
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
          // DropdownButtonFormField<String>(
          //   decoration: const InputDecoration(
          //     labelText: 'Choose language',
          //     border: OutlineInputBorder(),
          //   ),
          //   items: ['Vietnamese', 'English'].map((String language) {
          //     return DropdownMenuItem<String>(
          //       value: language,
          //       child: Text(language),
          //     );
          //   }).toList(),
          //   onChanged: (String? value) {},
          // ),
          // const SizedBox(height: 20),
          // const Text(
          //   'Selecting the appropriate language helps improve the quality of the recording',
          //   style: TextStyle(color: Colors.grey),
          // ),
          // const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                viewModel.pickAudioFile2(context);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.upload, color: Colors.white),
              label: const Text('Choose file to upload',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get tapOutsideToDismissKeyBoard => true;

  @override
  String get screenName => MainRoute.name;

  MainState get state => ref.watch(mainProvider);

  @override
  MainViewModel get viewModel => ref.read(mainProvider.notifier);
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
        Text(label,
            style: const TextStyle(
                color: Colors.purple, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class YouTubeLinkSheet extends StatefulWidget {
  final MainViewModel viewModel;

  const YouTubeLinkSheet({Key? key, required this.viewModel}) : super(key: key);

  @override
  _YouTubeLinkSheetState createState() => _YouTubeLinkSheetState();
}

class _YouTubeLinkSheetState extends State<YouTubeLinkSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // Giải phóng bộ nhớ
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tiêu đề và nút đóng
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
            RichText(
              text: const TextSpan(
                text: 'Please enter format url: ',
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: 'https://www.youtube.com/watch?v=videoId',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown chọn ngôn ngữ
            // DropdownButtonFormField<String>(
            //   decoration: const InputDecoration(
            //     labelText: 'Choose language',
            //     border: OutlineInputBorder(),
            //   ),
            //   items: ['Vietnamese', 'English'].map((String language) {
            //     return DropdownMenuItem<String>(
            //       value: language,
            //       child: Text(language),
            //     );
            //   }).toList(),
            //   onChanged: (String? value) {},
            // ),
            // const SizedBox(height: 20),
            // Trường nhập liệu cho YouTube link
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter YouTube link',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 20),
            // Nút bắt đầu
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  String youtubeLink = _controller.text.trim();
                  if (youtubeLink.isNotEmpty) {
                    // Xử lý URL để lấy key và videoTitle
                    Uri? uri = Uri.tryParse(youtubeLink);
                    if (uri != null &&
                        (uri.host.contains('youtube.com') ||
                            uri.host.contains('youtu.be'))) {
                      String? videoId;

                      if (uri.host.contains('youtu.be')) {
                        videoId = uri.pathSegments.last;
                      } else {
                        videoId = uri.queryParameters['v'];
                      }

                      if (videoId != null) {
                        widget.viewModel
                            .checkAndDownloadAudio(videoId, context);

                        Navigator.pop(context);
                      } else {
                        // Hiển thị thông báo lỗi nếu không lấy được videoId
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid YouTube link')),
                        );
                      }
                    } else {
                      // Hiển thị thông báo lỗi nếu URL không hợp lệ
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a valid YouTube link')),
                      );
                    }
                  } else {
                    // Hiển thị thông báo nếu trường nhập liệu trống
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter a YouTube link')),
                    );
                  }
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label:
                    const Text('Start', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
