import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:covid_dashboard/core/theme/anti_gravity_theme.dart';
import 'package:covid_dashboard/domain/entities/covid_record.dart';

class AgeDistributionChart extends StatefulWidget {
  final List<CovidRecord> data;

  const AgeDistributionChart({super.key, required this.data});

  @override
  State<AgeDistributionChart> createState() => _AgeDistributionChartState();
}

class _AgeDistributionChartState extends State<AgeDistributionChart> {
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

    // Binning ages
    Map<String, int> ageGroups = {
      '18-24': 0,
      '25-34': 0,
      '35-44': 0,
      '45-54': 0,
      '55+': 0,
    };

    for (var r in widget.data) {
      if (r.age <= 24) ageGroups['18-24'] = ageGroups['18-24']! + 1;
      else if (r.age <= 34) ageGroups['25-34'] = ageGroups['25-34']! + 1;
      else if (r.age <= 44) ageGroups['35-44'] = ageGroups['35-44']! + 1;
      else if (r.age <= 54) ageGroups['45-54'] = ageGroups['45-54']! + 1;
      else ageGroups['55+'] = ageGroups['55+']! + 1;
    }

    final sortedAgeGroupKeys = ageGroups.keys.toList();
    final values = ageGroups.values.toList();
    final maxValue = values.isEmpty ? 10.0 : values.reduce((a, b) => a > b ? a : b).toDouble();
    final isZoomed = _zoomLevel > 1.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Age Demographics',
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
              maxY: maxValue * 1.2,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < 0 || value.toInt() >= sortedAgeGroupKeys.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          sortedAgeGroupKeys[value.toInt()],
                          style: const TextStyle(color: AntiGravityTheme.textSecondaryColor, fontSize: 10),
                        ),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(sortedAgeGroupKeys.length, (i) {
                final count = values[i];
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: count.toDouble(),
                      color: AntiGravityTheme.accentColor,
                      width: 14 * _zoomLevel,
                      borderRadius: BorderRadius.circular(4),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxValue * 1.2,
                        color: AntiGravityTheme.surfaceColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                  showingTooltipIndicators: isZoomed ? [0] : [],
                );
              }),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  // tooltipBgColor: Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      rod.toY.round().toString(),
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
}
