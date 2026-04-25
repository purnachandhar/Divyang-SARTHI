import 'package:get/get.dart';
import '../controllers/parent_controller.dart';

class ParentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentController>(
      () => ParentController(),
    );
  }
}
