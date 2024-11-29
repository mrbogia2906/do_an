// upgrade_screen.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/base_view/base_view.dart';
import 'package:speech_to_text_app/components/loading/loading_view_model.dart';
import 'package:speech_to_text_app/data/providers_gen/current_user_notifier.dart';
import 'package:speech_to_text_app/data/repositories/auth/auth_local_repository.dart';
import 'package:speech_to_text_app/screen/upgrade/upgrade_state.dart';
import 'package:speech_to_text_app/screen/upgrade/upgrade_view_model.dart';

import '../../components/loading/container_with_loading.dart';
import '../../data/providers/transcription_provider.dart';
import '../../data/view_model/auth_viewmodel.dart';
import '../../router/app_router.dart';

final _provider =
    StateNotifierProvider.autoDispose<UpgradeViewModel, UpgradeState>(
  (ref) => UpgradeViewModel(
    ref: ref,
    authViewModel: ref.read(authViewModelProvider.notifier),
  ),
);

@RoutePage()
class UpgradeScreen extends BaseView {
  const UpgradeScreen({super.key});

  @override
  BaseViewState<UpgradeScreen, UpgradeViewModel> createState() =>
      _UpgradeViewState();
}

class _UpgradeViewState extends BaseViewState<UpgradeScreen, UpgradeViewModel> {
  // Giá cố định cho việc nâng cấp (ví dụ: 10,000 VNĐ)
  final int fixedPrice = 10000;

  @override
  Future<void> onInitState() async {
    super.onInitState();
    await Future.delayed(Duration.zero, () async {
      await _onInitData();
    });
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => AppBar(
        title: const Text("Nâng Cấp Tài Khoản"),
      );

  double get usageRatio {
    final transcriptionHistory = ref.watch(transcriptionProvider);
    final maxAudioFiles =
        ref.watch(currentUserNotifierProvider)?.maxAudioFiles ??
            1; // Tránh chia cho 0
    return transcriptionHistory.length / maxAudioFiles;
  }

  int get currentAudioFiles {
    return ref.watch(transcriptionProvider).length;
  }

  int get maxAudioFiles {
    return ref.watch(currentUserNotifierProvider)?.maxAudioFiles ?? 0;
  }

  @override
  Widget buildBody(BuildContext context) {
    final currentUser = ref.watch(currentUserNotifierProvider);
    // Kiểm tra trạng thái premium của người dùng
    final isPremium = currentUser?.isPremium ?? false;
    print("isPremium: $isPremium");

    // Lấy dữ liệu số lượng tệp âm thanh và giới hạn tối đa
    final transcriptionHistory = ref.watch(transcriptionProvider);
    final maxTotalAudioTime = currentUser?.maxTotalAudioTime ?? 1;
    final maxAudioFiles = currentUser?.maxAudioFiles ?? 1;
    final currentAudioFiles = transcriptionHistory.length;
    final currentTotalTime = currentUser?.totalAudioTime ?? 0;
    final usageRatioTotalFile =
        (maxAudioFiles > 0) ? (currentAudioFiles / maxAudioFiles) : 0.0;
    final usageRatioTotalTime =
        (maxTotalAudioTime > 0) ? (currentTotalTime / maxTotalAudioTime) : 0.0;

    return ContainerWithLoading(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Số tệp âm thanh hiện tại:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            LinearProgressIndicator(
              value: usageRatio.clamp(
                  0.0, 1.0), // Đảm bảo giá trị nằm trong khoảng 0 đến 1
              backgroundColor: Colors.grey[300],
              color: usageRatioTotalFile > 1.0
                  ? Colors.red
                  : Colors.blueAccent, // Màu đỏ nếu vượt quá giới hạn
              minHeight: 10,
            ),
            const SizedBox(height: 5),
            Text(
              "$currentAudioFiles / $maxAudioFiles tệp",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            const Text("Thời gian âm thanh đã sử dụng:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            LinearProgressIndicator(
              value: usageRatioTotalTime.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              color: usageRatioTotalTime > 1.0 ? Colors.red : Colors.blueAccent,
              minHeight: 10,
            ),
            const SizedBox(height: 5),
            Text(
              "${currentTotalTime ~/ 60} phút / ${maxTotalAudioTime ~/ 60} phút",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),

            // Hiển thị nội dung tùy thuộc vào trạng thái Premium
            if (isPremium) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 100),
                      SizedBox(height: 20),
                      Text(
                        "Congratulations! Your account is Premium.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const Text(
                "Price for upgrading to Premium:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "${fixedPrice.toString()} VNĐ",
                style: const TextStyle(fontSize: 24, color: Colors.green),
              ),
              // Hiển thị các ưu đãi khi nâng cấp
              const Text(
                "Advantages of Premium:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    _buildBenefitItem(
                        Icons.check_circle, "Increase limit of audio files"),
                    _buildBenefitItem(
                        Icons.check_circle, "Increase limit of audio time"),
                    _buildBenefitItem(
                        Icons.check_circle, "Access to advanced features"),
                    _buildBenefitItem(Icons.check_circle, "Support 24/7"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Nút Nâng Cấp
              state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _showConfirmationDialog(context);
                          },
                          child: const Text(
                            "Nâng Cấp",
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ],
        ),
      ),
    );
  }

  // Hàm xây dựng từng mục ưu đãi
  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  UpgradeViewModel get viewModel => ref.read(_provider.notifier);

  @override
  String get screenName => UpgradeRoute.name;

  UpgradeState get state => ref.watch(_provider);

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

  // Hàm hiển thị hộp thoại xác nhận nâng cấp
  Future<void> _showConfirmationDialog(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác Nhận Nâng Cấp"),
          content: Text(
              "Bạn có chắc chắn muốn nâng cấp tài khoản với giá ${fixedPrice.toString()} VNĐ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Xác Nhận"),
            ),
          ],
        );
      },
    );

    if (confirm != null && confirm) {
      await _handleUpgrade();
    }
  }

  // Hàm xử lý nâng cấp tài khoản
  Future<void> _handleUpgrade() async {
    try {
      // Lấy userId và authToken từ provider hoặc state
      String userId = ref.read(currentUserNotifierProvider)!.id;
      String authToken =
          await ref.read(authLocalRepositoryProvider).getToken() ?? "";

      // Gọi API nâng cấp tài khoản với giá cố định
      await viewModel.upgradeAccount(fixedPrice, authToken, userId);

      // Sau khi nhận được token thanh toán từ backend, chuyển hướng đến ZaloPay
      if (state.zpTransToken.isNotEmpty) {
        await viewModel.handlePayment(state.zpTransToken, userId, authToken);
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã xảy ra lỗi: ${e.toString()}")),
      );
    }
  }
}
