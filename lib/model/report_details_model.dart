
class BloodReportMetricModel {
  Map<String, ReportMetric> reportMetrics;
  String testDate;

  BloodReportMetricModel({
    required this.reportMetrics,
    this.testDate = "",
  });

  factory BloodReportMetricModel.fromJson(Map<String, dynamic> json) {
    return BloodReportMetricModel(
      reportMetrics: Map.from(json["reportMetrics"]).map(
        (k, v) => MapEntry<String, ReportMetric>(k, ReportMetric.fromJson(v)),
      ),
      testDate: json['testDate'] ,
    );
  }

  Map<String, dynamic> toJson() => {
    "reportMetrics": Map.from(reportMetrics).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
    "testDate": testDate,
  };
}

class ReportMetric {
  String upperBound;
  String lowerBound;
  String unit;
  String value;

  ReportMetric({
    this.upperBound = "",
    this.lowerBound = "",
     this.unit = "",
     this.value = "",
  });

  factory ReportMetric.fromJson(Map<String, dynamic> json) => ReportMetric(
    upperBound: json["upperBound"] ?? "",
    lowerBound: json["lowerBound"] ?? "",
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