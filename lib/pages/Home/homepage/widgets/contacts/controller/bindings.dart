import 'package:association/pages/Home/homepage/widgets/contacts/controller/contact_controller.dart';
import 'package:get/get.dart';

class MemberBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemberController>(() => MemberController());
  }
}
