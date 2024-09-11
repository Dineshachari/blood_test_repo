import 'package:blood_test_repo/services/api_service.dart';
import 'package:blood_test_repo/model/report_details_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class HomePageController extends GetxController {
  Rx<BloodReportModel?> report = Rx<BloodReportModel?>(null);
  RxBool isLoading = true.obs;
  RxString error = RxString('');

  @override
  void onInit() {
    super.onInit();
    fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      isLoading.value = true;
      final response = await ApiService.getReports(2);
      if (kDebugMode) {
        print('Status Code: ${response.statusCode}');
        print('Response Type: ${response.data.runtimeType}');
        print('Response Body: ${response.data}');
      }

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      if (response.data is List && response.data.isNotEmpty) {
        report.value = BloodReportModel.fromJson(response.data[0]);
        if (kDebugMode) {
          print('Parsed Report: ${report.value?.results.length} tests');
        }
      } else if (response.data is Map<String, dynamic>) {
        // If the response is a single object instead of a list
        report.value = BloodReportModel.fromJson(response.data);
        if (kDebugMode) {
          print('Parsed Report: ${report.value?.results.length} tests');
        }
      } else {
        throw Exception('Unexpected response format: ${response.data.runtimeType}');
      }

      isLoading.value = false;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error details: $e');
        print('Stack trace: $stackTrace');
      }
      error.value = e.toString();
      isLoading.value = false;
    }
  }
}