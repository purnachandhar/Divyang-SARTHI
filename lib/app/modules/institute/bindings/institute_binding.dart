import 'package:get/get.dart';
import '../controllers/institute_controller.dart';
import '../../../data/providers/api_provider.dart';

class InstituteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiProvider>(() => ApiProvider());
    Get.lazyPut<InstituteController>(
      () => InstituteController(),
    );
  }
}
