import 'package:super_talab_user/app/modules/search_module/search_controller.dart';
import 'package:get/get.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class searchBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => searchController());
  }
}