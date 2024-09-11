import 'dart:math';
import 'package:blood_test_repo/constant/app_colors.dart';
import 'package:blood_test_repo/model/report_details_model.dart';
import 'package:blood_test_repo/view_model/home_page_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
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

 Future<void> _refreshData() async {
    await homeVM.fetchReports();
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
          color: AppColors.textColor
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.white,
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
    ),
    body: Obx(() {
      if (homeVM.isLoading.value) {
        return _buildSkeletonLoading();
      } else if (homeVM.error.value.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshData,
        child: const Center(
            child: Text(
              "An error occurred. Please try again later.",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textColor,
              ),
            ),
          ),
      );
      } else if (homeVM.report.value == null || homeVM.report.value!.results.isEmpty) {
        return const Center(child: Text("No data available"));
      } else {
        return RefreshIndicator(
                      onRefresh: _refreshData,
          child: ListView(
            children: homeVM.report.value!.results.entries.map((entry) {
              final testName = entry.key;
              final testResult = entry.value;
              return _buildTestResultWidget(testName, testResult);
            }).toList(),
          ),
        );
      }
    }),
  );
}

Widget _buildTestResultWidget(String testName, TestResult testResult) {
  final double? lowerBound = testResult.normalRange?.isNotEmpty == true
      ? double.tryParse(testResult.normalRange![0])
      : null;
  final double? upperBound = testResult.normalRange?.length == 2
      ? double.tryParse(testResult.normalRange![1])
      : null;
  final double? latestResult = double.tryParse(testResult.latestResult ?? '');

  bool isNormal = true;
  if (latestResult != null && lowerBound != null && upperBound != null) {
    isNormal = latestResult >= lowerBound && latestResult <= upperBound;
  }

  return Container(
    width: Get.width,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                testName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ),
            Container(
              height: 27,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isNormal ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  isNormal ? "Normal" : "Abnormal",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
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
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${testResult.latestResult ?? 'N/A'} ${testResult.unit ?? ''}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          testResult.date ?? 'Date not available',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 10),
        _buildLineChart(testResult),
      ],
    ),
  );
}





Widget _buildLineChart(TestResult testResult) {
  final spots = testResult.historicalData.asMap().entries.map((entry) {
    final index = entry.key.toDouble();
    final value = double.tryParse(entry.value.value ?? '') ?? 0;
    return FlSpot(index, value);
  }).toList();

  final double? lowerBound = testResult.normalRange?.isNotEmpty == true
      ? double.tryParse(testResult.normalRange![0])
      : null;
  final double? upperBound = testResult.normalRange?.length == 2
      ? double.tryParse(testResult.normalRange![1])
      : null;

  if (lowerBound == null || upperBound == null) {
    return const Center(child: Text('Normal range not available'));
  }

  double minY = lowerBound;
  double maxY = upperBound;

  if (spots.isNotEmpty) {
    final dataMinY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final dataMaxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    minY = min(minY, dataMinY);
    maxY = max(maxY, dataMaxY);
  }

  final padding = (maxY - minY) * 0.1;
  minY -= padding;
  maxY += padding;

  return Container(
    height: 200,
    padding: const EdgeInsets.only(right: 16, top: 8),
    child: LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 5,
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
                if (value.toInt() >= 0 && value.toInt() < testResult.historicalData.length) {
                  final date = testResult.historicalData[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      date ?? '',
                      style: const TextStyle(
                        fontSize: 7,
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w500,
                      ),
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
              interval: (maxY - minY) / 5,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 7,
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: max(spots.length - 1.0, 1),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
               Color dotColor = Colors.blue;
                if (spot.y < lowerBound) {
                  dotColor = Colors.orange;
                } else if (spot.y > upperBound) {
                  dotColor = Colors.orange;
                } else {
                  dotColor = Colors.green;
                }
                return FlDotCirclePainter(
                  radius: 4,
                  color: dotColor,
                  strokeWidth: 2,
                  strokeColor:dotColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
                        color: Colors.transparent,
                        
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withOpacity(0.7),
                  Colors.green.withOpacity(0.7),
                  Colors.orange.withOpacity(0.7),
                ],
                                stops: [0, (upperBound - lowerBound) / maxY, 1],
                  begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              cutOffY: lowerBound,
              applyCutOffY: true,
            ),
          ),
        ],
        lineTouchData: LineTouchData(
                 enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueAccent,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                if (flSpot.x.toInt() >= 0 && flSpot.x.toInt() < testResult.historicalData.length) {
                  final date = testResult.historicalData[flSpot.x.toInt()].date;
                  return LineTooltipItem(
                    '${flSpot.y.toStringAsFixed(1)} ${testResult.unit}\n$date',
                    const TextStyle(color: Colors.white),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: lowerBound,
                        color: Colors.grey,

              strokeWidth: 1,
              dashArray: [5, 5],
            ),
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
