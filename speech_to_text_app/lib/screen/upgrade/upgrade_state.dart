import 'package:freezed_annotation/freezed_annotation.dart';

part 'upgrade_state.freezed.dart';

@freezed
class UpgradeState with _$UpgradeState {
  factory UpgradeState({
    @Default(false) bool isLoading,
    @Default('') String zpTransToken,
    @Default('') String orderUrl,
    @Default('') String payResult,
    @Default(false) bool showResult,
  }) = _UpgradeState;

  const UpgradeState._();
}
