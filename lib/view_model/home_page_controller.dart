import 'package:blood_test_repo/services/api_service.dart';
import 'package:blood_test_repo/model/report_details_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/state_manager.dart';

class HomePageController extends GetxController {
  RxList<BloodReportMetricModel> reports = <BloodReportMetricModel>[].obs;
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

      if (response.data is List) {
        reports.value = (response.data as List)
            .map((json) => BloodReportMetricModel.fromJson(json))
            .toList();
        isLoading.value = false;
      } else {
        throw Exception('Unexpected response format: ${response.data.runtimeType}');
      }

      if (kDebugMode) {
        print('Parsed Reports: ${reports.length}');
        if (reports.isNotEmpty) {
          print('First Report Metrics: ${reports.first.reportMetrics.keys.join(", ")}');
        }
      }

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