import 'package:get/get.dart';
import 'package:super_talab_user/app/modules/changeaddress_module/changeaddress_controller.dart';

/// GetX Template Generator - fb.com/htngu.99
///

class changeaddressBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => changeaddressController());
  }
}
