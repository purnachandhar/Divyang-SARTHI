import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentController extends GetxController {
  final currentIndex = 0.obs;

  void changeTabIndex(int index) {
    currentIndex.value = index;
  }

  void goToChildProfile(Map<String, String> child) {
    Get.toNamed('/parent-child-profile', arguments: child);
  }

  void goToAddChild() {
    Get.toNamed('/parent-add-child');
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_id');
    Get.offAllNamed('/login');
  }
}
