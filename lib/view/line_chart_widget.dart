import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class CholesterolChartWidget extends StatelessWidget {
  final List<CholesterolReading> readings;
  final double minNormal;
  final double maxNormal;

  const CholesterolChartWidget({
    super.key,
    required this.readings,
    this.minNormal = 200,
    this.maxNormal = 240,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildRangeIndicator(),
        const SizedBox(height: 20),
        _buildChart(),
      ],
    );
  }

  Widget _buildHeader() {
    final latestReading = readings.last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Cholesterol',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(latestReading.value),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatus(latestReading.value),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Your Latest Result', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          '${latestReading.value.toStringAsFixed(1)} mg/dL',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          DateFormat('d MMM yyyy').format(latestReading.date),
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRangeIndicator() {
    return Container(
      height: 20,
      child: CustomPaint(
        size: Size.infinite,
        painter: RangeIndicatorPainter(
          minNormal: minNormal,
          maxNormal: maxNormal,
          currentValue: readings.last.value,
        ),
      ),
    );
  }

  Widget _buildChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < readings.length) {
                    return Text(DateFormat('MMM').format(readings[value.toInt()].date).toUpperCase());
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: 300,
          lineBarsData: [
            LineChartBarData(
              spots: readings.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.value);
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: Colors.white,
                    strokeWidth: 3,
                    strokeColor: _getStatusColor(readings[index].value),
                  );
                },
              ),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(y: minNormal, color: Colors.green.withOpacity(0.8), strokeWidth: 2),
              HorizontalLine(y: maxNormal, color: Colors.red.withOpacity(0.8), strokeWidth: 2),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(double value) {
    if (value < minNormal) return Colors.green;
    if (value > maxNormal) return Colors.red;
    return Colors.orange;
  }

  String _getStatus(double value) {
    if (value < minNormal) return 'Normal';
    if (value > maxNormal) return 'Abnormal';
    return 'Borderline';
  }
}

class RangeIndicatorPainter extends CustomPainter {
  final double minNormal;
  final double maxNormal;
  final double currentValue;

  RangeIndicatorPainter({
    required this.minNormal,
    required this.maxNormal,
    required this.currentValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw background
    paint.color = Colors.grey[300]!;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(size.height / 2)), paint);

    // Draw normal range
    paint.color = Colors.green;
    final normalStart = size.width * (minNormal / 300);
    final normalWidth = size.width * ((maxNormal - minNormal) / 300);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(normalStart, 0, normalWidth, size.height), Radius.circular(size.height / 2)), paint);

    // Draw current value indicator
    paint.color = _getStatusColor(currentValue);
    final indicatorPosition = size.width * (currentValue / 300);
    canvas.drawCircle(Offset(indicatorPosition, size.height / 2), size.height / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Color _getStatusColor(double value) {
    if (value < minNormal) return Colors.green;
    if (value > maxNormal) return Colors.red;
    return Colors.orange;
  }
}

class CholesterolReading {
  final DateTime date;
  final double value;

  CholesterolReading(this.date, this.value);
}