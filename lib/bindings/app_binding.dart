
import 'package:blood_test_repo/view_model/home_page_controller.dart';
import 'package:get/instance_manager.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomePageController>(() => HomePageController()); 
  }
}