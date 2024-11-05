import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view_model.dart';
import 'package:speech_to_text_app/screen/upgrade/upgrade_state.dart';

class UpgradeViewModel extends BaseViewModel<UpgradeState> {
  UpgradeViewModel({
    required this.ref,
  }) : super(UpgradeState());

  final Ref ref;

  Future<void> initData() async {}
}
