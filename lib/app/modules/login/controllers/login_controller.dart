import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/providers/api_provider.dart';
import '../../../utils/jwt_utils.dart';

class LoginController extends GetxController {
  final ApiProvider _apiProvider = Get.put(ApiProvider());
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final captchaController = TextEditingController();

  var isPasswordVisible = false.obs;
  var isOtpMode = false.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void onGetOtp() {
    isOtpMode.value = true;
    Get.snackbar(
      'OTP Sent',
      'One Time Password has been sent to your mobile number.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onLogin() async {
    // Basic validation
    if (phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your login ID',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }
    if (passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final response = await _apiProvider.login(
          phoneController.text, passwordController.text);

      print("The response of the login is ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        String accessToken = response.body['accessToken'] ?? '';
        String userId = response.body['id'] ?? '';
        if (accessToken.isNotEmpty) {
          // Persist token and user id for authenticated API calls
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', accessToken);
          await prefs.setString('user_id', userId);

          Map<String, dynamic> payload = JwtUtils.decodeJWT(accessToken);
          List<dynamic> roles = payload['roles'] ?? [];

          if (roles.contains('Institute')) {
            Get.offAllNamed('/institute-home');
          } else if (roles.contains('Parent')) {
            Get.offAllNamed('/parent-home');
          } else {
            // Defaulting to educator/professional
            Get.offAllNamed('/educator-home');
          }
        } else {
          Get.snackbar("Error", "Invalid token received.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      } else {
        String errorMessage = "Login failed";
        if (response.body != null &&
            response.body is Map &&
            response.body['message'] != null) {
          errorMessage = response.body['message'];
        }
        Get.snackbar("Login Failed", errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.9),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred: ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void onLoginWithParichay() {
    Get.snackbar(
      'Parichay Login',
      'Redirecting to Parichay secure login...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    captchaController.dispose();
    super.onClose();
  }
}
