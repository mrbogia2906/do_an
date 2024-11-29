// upgrade_view_model.dart
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text_app/data/view_model/auth_viewmodel.dart';
import 'dart:convert';

import '../../components/base_view/base_view_model.dart';
import '../../data/models/api/responses/create_order_response/create_order_response.dart';
import '../../data/repositories/api/payment/payment.dart';
import '../../utilities/constants/server_constants.dart';
import 'upgrade_state.dart';

class UpgradeViewModel extends BaseViewModel<UpgradeState> {
  UpgradeViewModel({
    required this.ref,
    required this.authViewModel,
  }) : super(UpgradeState());
  final Ref ref;

  final String baseUrl = "${ServerConstant.serverURL}/api";

  AuthViewModel authViewModel;

  Future<void> initData() async {
    state = state.copyWith(
      isLoading: false,
      showResult: false,
      payResult: "",
      zpTransToken: "",
      orderUrl: "",
    );
  }

  Future<void> upgradeAccount(
      int amount, String authToken, String userId) async {
    try {
      state = state.copyWith(isLoading: true);
      print("Creating order with amount: $amount");
      // Tạo đơn hàng
      CreateOrderResponse orderResponse = await createOrder(amount);
      print("CreateOrderResponse: ${orderResponse.toJson()}");

      if (orderResponse.returncode == 1) {
        // Lưu zpTransToken và orderUrl để sử dụng khi thanh toán
        state = state.copyWith(
          zpTransToken: orderResponse.zptranstoken,
          orderUrl: orderResponse.orderurl,
          isLoading: false,
          showResult: true,
          payResult: "",
        );
        print(
            "Order created successfully with zptranstoken: ${orderResponse.zptranstoken}");
      } else {
        state = state.copyWith(
          isLoading: false,
          payResult: orderResponse.returnmessage,
          showResult: true,
        );
        print("Order creation failed: ${orderResponse.returnmessage}");
      }
    } catch (e) {
      print("Error in upgradeAccount: $e");
      state = state.copyWith(
        isLoading: false,
        payResult: "Có lỗi xảy ra: $e",
        showResult: true,
      );
    }
  }

  Future<void> handlePayment(
      String zpToken, String userId, String authToken) async {
    try {
      state = state.copyWith(isLoading: true);
      print("Handling payment with zpToken: $zpToken");

      // Gọi phương thức native để thực hiện thanh toán
      const MethodChannel platform =
          MethodChannel('flutter.native/channelPayOrder');
      final String result =
          await platform.invokeMethod('payOrder', {"zptoken": zpToken});
      print("payOrder Result: '$result'.");

      if (result == "Payment Success") {
        // Gọi endpoint backend để cập nhật trạng thái thanh toán
        print("Calling backend callback endpoint");
        final response = await http.post(
          Uri.parse('$baseUrl/payment/callback'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': authToken,
          },
          body: jsonEncode({
            'user_id': userId,
            'status': 'success',
          }),
        );

        print(
            "Backend callback response: ${response.statusCode} - ${response.body}");

        if (response.statusCode == 200) {
          print("Payment callback successful");
          state = state.copyWith(
            payResult: "Thanh toán thành công và tài khoản đã được nâng cấp!",
            isLoading: false,
          );
        } else {
          print(
              "Payment callback failed: ${response.statusCode} - ${response.body}");
          state = state.copyWith(
            payResult:
                "Thanh toán thành công nhưng không thể nâng cấp tài khoản.",
            isLoading: false,
          );
        }
      } else if (result == "User Canceled") {
        print("User canceled payment");
        state = state.copyWith(
          payResult: "Bạn đã hủy thanh toán.",
          isLoading: false,
        );
      } else {
        print("Payment failed");
        state = state.copyWith(
          payResult: "Thanh toán thất bại.",
          isLoading: false,
        );
      }
    } on PlatformException catch (e) {
      print("Failed to Invoke: '${e.message}'.");
      state = state.copyWith(
        isLoading: false,
        payResult: "Thanh toán thất bại: ${e.message}",
      );
    } catch (e) {
      print("Error in handlePayment: $e");
      state = state.copyWith(
        isLoading: false,
        payResult: "Có lỗi xảy ra: $e",
      );
    }
    authViewModel.getCurrentUserData();
  }

  // Hàm cập nhật trạng thái premium của người dùng
  // Future<void> updateUserPremiumStatus(String userId, String authToken) async {
  //   try {
  //     // Gọi API để cập nhật trạng thái premium
  //     await yourApiService.updateUserPremiumStatus(userId, authToken);

  //     // Cập nhật provider currentUserNotifierProvider
  //     ref.read(currentUserNotifierProvider.notifier).setPremium(true);
  //   } catch (e) {
  //     throw e;
  //   }
  // }
}
