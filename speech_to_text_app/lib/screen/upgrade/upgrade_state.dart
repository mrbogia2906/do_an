import 'package:freezed_annotation/freezed_annotation.dart';

part 'upgrade_state.freezed.dart';

@freezed
class UpgradeState with _$UpgradeState {
  factory UpgradeState({
    @Default(true) bool loading,
  }) = _UpgradeState;

  const UpgradeState._();
}
