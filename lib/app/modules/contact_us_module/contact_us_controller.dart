import 'package:get/get.dart';

import '../../data/services/FirebaseHelper.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class ContactUsController extends GetxController{

  var address = ''.obs;
  var phone = ''.obs;
  var email = ''.obs;


  void initState() {
    FireStoreUtils().getContactUs().then((value) {
        address = value['Address'];
        phone = value['Phone'];
        email = value['Email'];
      });
  }

}
