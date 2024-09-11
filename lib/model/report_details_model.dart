import 'dart:convert';

class BloodReportMetricModel {
  Map<String, ReportMetric> reportMetrics;
  DateTime? testDate;

  BloodReportMetricModel({
    required this.reportMetrics,
    this.testDate,
  });

 factory BloodReportMetricModel.fromJson(Map<String, dynamic> json) {
  final reportDetailsString = json['reportDetails'] as String;
  final reportDetailsJson = jsonDecode(reportDetailsString);
  
  return BloodReportMetricModel(
    reportMetrics: Map.from(reportDetailsJson["reportMetrics"]).map(
      (k, v) => MapEntry<String, ReportMetric>(k, ReportMetric.fromJson(v)),
    ),
    testDate: json['testDate'] != null ? DateTime.parse(json['testDate']) : null,
  );
}

  Map<String, dynamic> toJson() => {
    "reportMetrics": Map.from(reportMetrics).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
    "testDate": testDate?.toIso8601String(),
  };
}

class ReportMetric {
  String? upperBound;
  String? lowerBound;
  String unit;
  String value;

  ReportMetric({
    this.upperBound,
    this.lowerBound,
    required this.unit,
    required this.value,
  });

  factory ReportMetric.fromJson(Map<String, dynamic> json) => ReportMetric(
    upperBound: json["upperBound"],
    lowerBound: json["lowerBound"],
    unit: json["unit"] ?? "",
    value: json["value"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "upperBound": upperBound,
    "lowerBound": lowerBound,
    "unit": unit,
    "value": value,
  };
}