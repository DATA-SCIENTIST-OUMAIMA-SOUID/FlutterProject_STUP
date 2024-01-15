import 'package:super_talab_user/app/modules/cart_module/cart_controller.dart';
import 'package:get/get.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class cartBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => cartController());
  }
}