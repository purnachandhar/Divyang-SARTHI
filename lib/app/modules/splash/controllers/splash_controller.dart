import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/jwt_utils.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');
    final bool isOnboardingDone = prefs.getBool('is_onboarding_done') ?? false;

    if (accessToken != null && accessToken.isNotEmpty) {
      try {
        final Map<String, dynamic> payload = JwtUtils.decodeJWT(accessToken);
        final List<dynamic> roles = payload['roles'] ?? [];

        if (roles.contains('Institute')) {
          Get.offAllNamed('/institute-home');
          return;
        } else if (roles.contains('Parent')) {
          Get.offAllNamed('/parent-home');
          return;
        } else {
          // Defaulting to educator/professional
          Get.offAllNamed('/educator-home');
          return;
        }
      } catch (e) {
        print('Error decoding token: $e');
        // If token is invalid, fall through to login/onboarding
      }
    }

    if (isOnboardingDone) {
      Get.offNamed('/login');
    } else {
      Get.offNamed('/onboarding');
    }
  }
}
