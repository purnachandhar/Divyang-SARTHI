import 'package:get/get.dart';
import '../controllers/educator_controller.dart';

class EducatorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EducatorController>(
      () => EducatorController(),
    );
  }
}
