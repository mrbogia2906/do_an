import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view.dart';
import 'package:speech_to_text_app/components/loading/loading_view_model.dart';
import 'package:speech_to_text_app/screen/account/account_screen.dart';
import 'package:speech_to_text_app/screen/account/account_state.dart';
import 'package:speech_to_text_app/screen/home/home_state.dart';
import 'package:speech_to_text_app/screen/home/home_view_model.dart';
import 'package:speech_to_text_app/screen/main/main_screen.dart';
import 'package:speech_to_text_app/screen/main/main_state.dart';
import 'package:speech_to_text_app/screen/main/main_view_model.dart';

import '../../router/app_router.dart';

final _provider = StateNotifierProvider<HomeViewModel, HomeState>(
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
    print(
        'transcriptionHistory: ${state.transcriptionHistory}, audioPath: ${state.audioPath}, mainAudio: ${mainState.audioPath}, mainIsLoading: ${mainState.isLoading}, accountLoading: ${accountState.loading}, transcriptionHistory: ${mainState.transcriptionHistory.length}');
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UpgradeWidget(),
            const SizedBox(height: 24.0),
            const SearchBarWidget(),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () =>
                  viewModel.sendToTranscription('gemini-transcribe').then((_) {
                viewModel.updateState();
              }),
              child: Text('Send for Gemini AI Transcription'),
            ),
            Expanded(
              child: mainState.transcriptionHistory.isNotEmpty
                  ? ListView.builder(
                      itemCount: mainState.transcriptionHistory.length,
                      itemBuilder: (context, index) {
                        final entry = mainState.transcriptionHistory[index];
                        return RecordingTile(
                          title: entry.title,
                          subtitle: entry.content,
                          trailingText:
                              entry.timestamp.toString().split(' ')[0],
                        );
                      })
                  : const Center(
                      child: Text('No recordings yet'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  HomeViewModel get viewModel => ref.read(_provider.notifier);

  @override
  String get screenName => HomeRoute.name;

  HomeState get state => ref.watch(_provider);

  MainState get mainState => ref.watch(mainProvider);

  AccountState get accountState => ref.watch(accountProvider);

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

class RecordingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailingText;

  const RecordingTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Text(title,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4.0),
          Text(subtitle,
              style: const TextStyle(fontSize: 14.0, color: Colors.black87)),
          const SizedBox(height: 4.0),
          Text(trailingText,
              style: const TextStyle(fontSize: 12.0, color: Colors.black54)),
        ],
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
