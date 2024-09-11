class BloodReportModel {
  final Map<String, TestResult> results;

  BloodReportModel({required this.results});

  factory BloodReportModel.fromJson(Map<String, dynamic> json) {
    Map<String, TestResult> results = {};
    json.forEach((key, value) {
      results[key] = TestResult.fromJson(value);
    });
    return BloodReportModel(results: results);
  }
}

class TestResult {
  final String? date;
  final List<HistoricalDatum> historicalData;
  final String? latestResult;
  final List<String>? normalRange;
  final String? testName;
  final String? unit;

  TestResult({
    this.date,
    required this.historicalData,
    this.latestResult,
    this.normalRange,
    this.testName,
    this.unit,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      date: json["date"],
      historicalData: (json["historicalData"] as List?)
          ?.map((x) => HistoricalDatum.fromJson(x))
          .toList() ?? [],
      latestResult: json["latestResult"]?.toString(),
      normalRange: (json["normalRange"] as List?)
          ?.map((x) => x.toString())
          .toList(),
      testName: json["testName"],
      unit: json["unit"],
    );
  }
}

class HistoricalDatum {
  final String? date;
  final String? value;

  HistoricalDatum({this.date, this.value});

  factory HistoricalDatum.fromJson(Map<String, dynamic> json) {
    return HistoricalDatum(
      date: json["date"],
      value: json["value"]?.toString(),
    );
  }
}