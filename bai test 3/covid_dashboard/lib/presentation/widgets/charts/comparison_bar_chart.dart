import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:covid_dashboard/core/theme/anti_gravity_theme.dart';
import 'package:covid_dashboard/domain/entities/covid_record.dart';

class ComparisonBarChart extends StatefulWidget {
  final List<CovidRecord> data;

  const ComparisonBarChart({super.key, required this.data});

  @override
  State<ComparisonBarChart> createState() => _ComparisonBarChartState();
}

class _ComparisonBarChartState extends State<ComparisonBarChart> {
  double _zoomLevel = 1.0;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text(
          'No Data available',
          style: TextStyle(color: AntiGravityTheme.textSecondaryColor),
        ),
      );
    }

    // Calculate Averages for the period
    double avgMasks = 0;
    double avgHands = 0;
    double avgStayHome = 0;
    double avgFear = 0;

    for (var r in widget.data) {
      avgMasks += r.maskUsage;
      avgHands += r.handWashing;
      avgStayHome += r.stayHome;
      avgFear += r.fearIndex;
    }

    final count = widget.data.length;
    avgMasks /= count;
    avgHands /= count;
    avgStayHome /= count;
    avgFear /= count;

    final isZoomed = _zoomLevel > 1.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Averaged Comparisons',
              style: TextStyle(
                color: AntiGravityTheme.textPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              width: 80,
              height: 20,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                ),
                child: Slider(
                  value: _zoomLevel,
                  min: 1.0,
                  max: 2.5,
                  activeColor: AntiGravityTheme.accentColor,
                  onChanged: (v) => setState(() => _zoomLevel = v),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 10,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      String label = '';
                      switch (value.toInt()) {
                        case 0: label = 'Masks'; break;
                        case 1: label = 'Hands'; break;
                        case 2: label = 'Stay Home'; break;
                        case 3: label = 'Fear Idx'; break;
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          label,
                          style: const TextStyle(color: AntiGravityTheme.textSecondaryColor, fontSize: 10),
                        ),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const Text('Poor', style: TextStyle(color: AntiGravityTheme.textSecondaryColor, fontSize: 9));
                      if (value == 5) return const Text('Med', style: TextStyle(color: AntiGravityTheme.textSecondaryColor, fontSize: 9));
                      if (value == 10) return const Text('Max', style: TextStyle(color: AntiGravityTheme.textSecondaryColor, fontSize: 9));
                      return const SizedBox.shrink();
                    },
                    reservedSize: 30,
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => const FlLine(
                  color: Color(0xFF3B3D4F),
                  strokeWidth: 0.5,
                  dashArray: [5, 5],
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                _buildGroup(0, avgMasks * 2.5, AntiGravityTheme.accentColor, isZoomed, 16 * _zoomLevel),
                _buildGroup(1, avgHands * 2.5, AntiGravityTheme.secondaryAccent, isZoomed, 16 * _zoomLevel),
                _buildGroup(2, avgStayHome * 2.5, const Color(0xFF64FFDA), isZoomed, 16 * _zoomLevel),
                _buildGroup(3, avgFear, const Color(0xFFFF5252), isZoomed, 16 * _zoomLevel),
              ],
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      rod.toY.toStringAsFixed(1),
                      const TextStyle(
                        color: AntiGravityTheme.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildGroup(int x, double y, Color color, bool showValue, double width) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: width,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
      showingTooltipIndicators: showValue ? [0] : [],
    );
  }
}
