import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:covid_dashboard/core/theme/anti_gravity_theme.dart';
import 'package:covid_dashboard/domain/entities/covid_record.dart';

class RegionPieChart extends StatefulWidget {
  final List<CovidRecord> data;

  const RegionPieChart({super.key, required this.data});

  @override
  State<RegionPieChart> createState() => _RegionPieChartState();
}

class _RegionPieChartState extends State<RegionPieChart> {
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

    // Group by region
    Map<String, int> regionCounts = {};
    for (var r in widget.data) {
      regionCounts[r.region] = (regionCounts[r.region] ?? 0) + 1;
    }

    final total = widget.data.length;
    final sortedEntries = regionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Define colors for regions
    final colors = [
      AntiGravityTheme.accentColor,
      AntiGravityTheme.secondaryAccent,
      const Color(0xFF64FFDA),
      const Color(0xFFFFD740),
      const Color(0xFFFF5252),
      const Color(0xFF7C4DFF),
    ];

    final isZoomed = _zoomLevel > 1.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Regional Distribution',
              overflow: TextOverflow.ellipsis,
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
        const SizedBox(height: 8),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Transform.scale(
                  scale: _zoomLevel,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 15 / _zoomLevel,
                      sections: List.generate(
                        sortedEntries.length > colors.length ? colors.length : sortedEntries.length,
                        (i) {
                          final entry = sortedEntries[i];
                          final percentage = (entry.value / total * 100);
                          return PieChartSectionData(
                            color: colors[i % colors.length],
                            value: entry.value.toDouble(),
                            title: isZoomed
                              ? '${entry.value}\n(${percentage.toStringAsFixed(0)}%)'
                              : '${percentage.toStringAsFixed(0)}%',
                            radius: 25,
                            titleStyle: TextStyle(
                              fontSize: isZoomed ? 8 : 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      sortedEntries.length > colors.length ? colors.length : sortedEntries.length,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: _buildLegendItem(sortedEntries[i].key, colors[i % colors.length]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              color: AntiGravityTheme.textSecondaryColor, 
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
