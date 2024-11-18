// lib/screen/audio_details/audio_details_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view_model.dart';
import 'package:speech_to_text_app/screen/audio_details/audio_details_state.dart';

class AudioDetailsViewModel extends BaseViewModel<AudioDetailsState> {
  AudioDetailsViewModel({
    required this.ref,
  }) : super(AudioDetailsState());

  final Ref ref;

  Future<void> initData() async {}
}
