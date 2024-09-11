import 'package:blood_test_repo/constant/app_colors.dart';
import 'package:blood_test_repo/model/report_details_model.dart';
import 'package:blood_test_repo/view_model/home_page_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final homeVM = HomePageController();

  @override
  void initState() {
    homeVM.fetchReports();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: const Text(
          "Your Analysis is ready!",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: Obx(() {
        if (homeVM.isLoading.value) {
          return _buildSkeletonLoading();
        } else if (homeVM.error.value.isNotEmpty) {
          return Center(child: Text("Error: ${homeVM.error.value}"));
        } else if (homeVM.reports.isEmpty) {
          return const Center(child: Text("No data available"));
        } else {
          return ListView(
            children: homeVM.reports.first.reportMetrics.keys.map((metric) {
              final reportMetric = homeVM.reports.first.reportMetrics[metric];
              if (reportMetric == null || reportMetric.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  Container(
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(metric,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textColor)),
                            ),
                           
                            Container(
                              height: 27,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                  color: const Color(0xffCBD0DC),
                                  borderRadius: BorderRadius.circular(20)),
                              child: const Center(
                                child: Text(
                                  "Normal",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textColor),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Your Latest Result",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: AppColors.textColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${reportMetric.value} ${reportMetric.unit}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor),
                        ),
                        const SizedBox(height: 8),
                        Text(     homeVM.reports.first.testDate ,
                          // DateFormat('d MMM yyyy').format(
                          //     homeVM.reports.first.testDate ?? DateTime.now()
                              
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: AppColors.textColor),
                        ),
                        const SizedBox(height: 10),
                        _buildLineChart(homeVM.reports, metric),
                      ],
                    ),
                  ),
                  Container(
                    height: 10,
                    color: Colors.white,
                  )
                ],
              );
            }).toList(),
          );
        }
      }),
    );
  }

  Widget _buildLineChart(List<BloodReportMetricModel> data, String metric) {
    final spots = data.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final value =
          double.tryParse(entry.value.reportMetrics[metric]?.value ?? '') ?? 0;
      return FlSpot(index, value);
    }).toList();

    spots.removeWhere((spot) => spot.y == 0);

    if (spots.isEmpty) {
      return const Center(child: Text('No data available for this metric'));
    }

    if (spots.length == 1) {
      spots.add(FlSpot(1, spots[0].y));
    }

    double minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    final ReportMetric? currentMetric = data.first.reportMetrics[metric];
    final double? lowerBound = double.tryParse(currentMetric?.lowerBound ?? '');
    final double? upperBound = double.tryParse(currentMetric?.upperBound ?? '');

    if (lowerBound != null && upperBound != null) {
      minY = minY < lowerBound ? minY : lowerBound;
      maxY = maxY > upperBound ? maxY : upperBound;
    }

    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }

    final interval = (maxY - minY) / 6;

    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 16, top: 8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300],
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < data.length) {
                    final date = data[value.toInt()].testDate;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        date,
                        style: const TextStyle(
                            fontSize: 7,
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w500),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 7,
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w500),
                  );
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: spots.length - 1.0,
          minY: minY - (maxY - minY) * 0.1,
          maxY: maxY + (maxY - minY) * 0.1,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.2),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.4),
                    Colors.blue.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: spots.length > 1,
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              if (lowerBound != null)
                HorizontalLine(
                  y: lowerBound,
                  color: Colors.grey,
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              if (upperBound != null)
                HorizontalLine(
                  y: upperBound,
                  color: Colors.grey,
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    String year = date.year.toString();
    if (year.startsWith('202X')) {
      year = '2023';
    }
    return DateFormat('MMM yyyy')
        .format(DateTime(int.parse(year), date.month, date.day));
  }

  Widget _buildSkeletonLoading() {
    return SkeletonTheme(
      shimmerGradient: LinearGradient(
        colors: [
          Colors.grey[300]!,
          Colors.grey[200]!,
          Colors.grey[300]!,
        ],
        stops: const [0.1, 0.5, 0.9],
      ),
      child: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            margin: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SkeletonItem(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(
                      style: SkeletonLineStyle(
                          width: 120,
                          height: 20,
                          borderRadius: BorderRadius.circular(12))),
                  const SizedBox(height: 8),
                  SkeletonLine(
                      style: SkeletonLineStyle(
                          width: 80,
                          height: 12,
                          borderRadius: BorderRadius.circular(12))),
                  const SizedBox(height: 8),
                  SkeletonLine(
                      style: SkeletonLineStyle(
                          width: 160,
                          height: 18,
                          borderRadius: BorderRadius.circular(12))),
                  const SizedBox(height: 10),
                  const SkeletonAvatar(
                      style: SkeletonAvatarStyle(
                          height: 200, width: double.infinity)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
