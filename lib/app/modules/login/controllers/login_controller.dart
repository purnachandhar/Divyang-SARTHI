import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/providers/api_provider.dart';
import 'dart:convert';
import '../../../utils/jwt_utils.dart';
class LoginController extends GetxController {
  final ApiProvider _apiProvider = Get.put(ApiProvider());
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final captchaController = TextEditingController();

  var isPasswordVisible = false.obs;
  var isOtpMode = false.obs;
  var isLoading = false.obs;
  
  // Captcha states
  var captchaSvg = ''.obs;
  var isMathCaptcha = false.obs;
  var captchaVerified = false.obs;
  var isFetchingCaptcha = false.obs;
  String correctCaptchaAnswer = '';
  var captchaId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVisualCaptcha();
  }

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

  // --- Captcha Methods ---

  Future<void> fetchVisualCaptcha() async {
    isFetchingCaptcha.value = true;
    captchaVerified.value = false;
    captchaController.clear();
    try {
      final response = await GetConnect().get('https://backend.divyangsarthi.in/recaptcha/visual');
      if (response.statusCode == 200) {
        final data = response.body;
        if (data != null && data['success'] == true) {
          captchaSvg.value = data['captchaSvg'] ?? '';
          captchaId.value = data['captchaId'] ?? '';
          _extractVisualAnswer(captchaSvg.value);
        }
      } else {
        Get.snackbar("Error", "Failed to load visual captcha", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load visual captcha: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isFetchingCaptcha.value = false;
    }
  }

  Future<void> fetchMathCaptcha() async {
    isFetchingCaptcha.value = true;
    captchaVerified.value = false;
    captchaController.clear();
    try {
      final response = await GetConnect().get('https://backend.divyangsarthi.in/recaptcha/math');
      if (response.statusCode == 200) {
        final data = response.body;
        if (data != null && data['success'] == true) {
          captchaSvg.value = data['questionSvg'] ?? '';
          captchaId.value = data['captchaId'] ?? '';
          _extractMathAnswer(data['question'] ?? '');
        }
      } else {
        Get.snackbar("Error", "Failed to load math captcha", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load math captcha: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isFetchingCaptcha.value = false;
    }
  }

  void _extractVisualAnswer(String svg) {
    final RegExp textRegExp = RegExp(r'<text[^>]*>([^<]+)</text>');
    final Iterable<Match> matches = textRegExp.allMatches(svg);
    String answer = '';
    for (var match in matches) {
      answer += match.group(1)?.trim() ?? '';
    }
    correctCaptchaAnswer = answer;
  }

  void _extractMathAnswer(String question) {
    try {
      final parts = question.split(' ');
      if (parts.length == 3) {
        final a = int.parse(parts[0]);
        final op = parts[1];
        final b = int.parse(parts[2]);
        if (op == '+') correctCaptchaAnswer = (a + b).toString();
        else if (op == '-') correctCaptchaAnswer = (a - b).toString();
        else if (op == '*') correctCaptchaAnswer = (a * b).toString();
        else if (op == '/') correctCaptchaAnswer = (a ~/ b).toString();
        else correctCaptchaAnswer = '';
      }
    } catch (e) {
      print("Math parse error: $e");
      correctCaptchaAnswer = '';
    }
  }

  void verifyCaptcha() {
    if (captchaController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter captcha code", 
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Colors.red, 
        colorText: Colors.white);
      return;
    }

    // Case-insensitive validation for visual, exact for math
    if (captchaController.text.trim().toLowerCase() == correctCaptchaAnswer.toLowerCase()) {
      captchaVerified.value = true;
      Get.snackbar("Success", "✓ Captcha verified successfully", 
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Colors.green, 
        colorText: Colors.white);
    } else {
      captchaVerified.value = false;
      Get.snackbar("Error", "Invalid captcha code. Please try again.", 
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Colors.red, 
        colorText: Colors.white);
      // Refresh captcha on failure
      refreshCaptcha();
    }
  }

  void refreshCaptcha() {
    if (isMathCaptcha.value) {
      fetchMathCaptcha();
    } else {
      fetchVisualCaptcha();
    }
  }

  void toggleCaptchaType() {
    isMathCaptcha.value = !isMathCaptcha.value;
    refreshCaptcha();
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    captchaController.dispose();
    super.onClose();
  }
}
