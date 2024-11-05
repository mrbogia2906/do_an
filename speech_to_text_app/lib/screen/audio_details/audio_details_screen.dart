import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view.dart';
import 'package:speech_to_text_app/components/loading/loading_view_model.dart';
import 'package:speech_to_text_app/screen/audio_details/audio_details_state.dart';
import 'package:speech_to_text_app/screen/audio_details/audio_details_view_model.dart';

import '../../router/app_router.dart';

final _provider =
    StateNotifierProvider.autoDispose<AudioDetailsViewModel, AudioDetailsState>(
  (ref) => AudioDetailsViewModel(
    ref: ref,
  ),
);

@RoutePage()
class AudioDetailsScreen extends BaseView {
  const AudioDetailsScreen({super.key});

  @override
  BaseViewState<AudioDetailsScreen, AudioDetailsViewModel> createState() =>
      _AudioDetailsViewState();
}

class _AudioDetailsViewState
    extends BaseViewState<AudioDetailsScreen, AudioDetailsViewModel> {
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
    return Container();
  }

  @override
  AudioDetailsViewModel get viewModel => ref.read(_provider.notifier);

  @override
  String get screenName => AudioDetailsRoute.name;

  AudioDetailsState get state => ref.watch(_provider);

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
