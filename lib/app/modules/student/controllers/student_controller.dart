import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentController extends GetxController {
  final currentIndex = 0.obs;

  // Student data passed from login/detail view
  final _studentData = <String, dynamic>{}.obs;

  String get studentName =>
      _studentData['fullName'] ?? _studentData['name'] ?? 'Student';
  String get studentEnrollment =>
      _studentData['enrollmentNumber'] ?? _studentData['enrollment'] ?? '';
  String get studentClass => _studentData['class'] ?? '';
  String get studentDP => _studentData['studentDP'] ?? '';
  String get gender => _studentData['gender'] ?? '';
  String get studentId => _studentData['_id'] ?? _studentData['id'] ?? '';

  @override
  void onInit() {
    super.onInit();
    // Load student info from arguments if available
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _studentData.value = args;
    } else if (args is Map) {
      _studentData.value = Map<String, dynamic>.from(args);
    }
  }

  void changeTabIndex(int index) {
    currentIndex.value = index;
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_id');
    Get.offAllNamed('/login');
  }
}
