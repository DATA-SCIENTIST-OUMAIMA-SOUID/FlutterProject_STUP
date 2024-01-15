import 'package:super_talab_user/app/modules/auth_module/auth_controller.dart';
import 'package:get/get.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class authBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => authController());
  }
}