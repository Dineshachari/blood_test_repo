import 'package:blood_test_repo/bindings/app_binding.dart';
import 'package:blood_test_repo/home_page.dart';
import 'package:blood_test_repo/view_model/home_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialBinding: AppBindings(),
      home:  const HomePage(),
    );
  }
}

