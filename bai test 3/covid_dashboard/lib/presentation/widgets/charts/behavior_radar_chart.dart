import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:covid_dashboard/core/theme/anti_gravity_theme.dart';
import 'package:covid_dashboard/domain/entities/covid_record.dart';

class BehaviorRadarChart extends StatefulWidget {
  final List<CovidRecord> data;

  const BehaviorRadarChart({super.key, required this.data});

  @override
  State<BehaviorRadarChart> createState() => _BehaviorRadarChartState();
}

class _BehaviorRadarChartState extends State<BehaviorRadarChart> {
  double _zoomLevel = 1.0;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text(
          'No Data for selected range',
          style: TextStyle(color: AntiGravityTheme.textSecondaryColor),
        ),
      );
    }

    // Calculate Averages
    double avgMasks = 0;
    double avgHands = 0;
    double avgGatherings = 0;
    double avgCrowds = 0;
    double avgStayHome = 0;
    double avgFear = 0;

    for (var r in widget.data) {
      avgMasks += r.maskUsage;
      avgHands += r.handWashing;
      avgGatherings += r.avoidGatherings;
      avgCrowds += r.avoidCrowds;
      avgStayHome += r.stayHome;
      avgFear += (r.fearIndex * 0.4); 
    }

    final count = widget.data.length;
    avgMasks /= count;
    avgHands /= count;
    avgGatherings /= count;
    avgCrowds /= count;
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
              'Multi-Behavioral Profile',
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
                  max: 3.0,
                  activeColor: AntiGravityTheme.accentColor,
                  onChanged: (v) => setState(() => _zoomLevel = v),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Averaged indicators',
          style: TextStyle(color: AntiGravityTheme.textSecondaryColor, fontSize: 10),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Transform.scale(
            scale: _zoomLevel,
            child: RadarChart(
              RadarChartData(
                radarTouchData: RadarTouchData(enabled: true),
                dataSets: [
                  RadarDataSet(
                    fillColor: AntiGravityTheme.accentColor.withOpacity(0.2),
                    borderColor: AntiGravityTheme.accentColor,
                    entryRadius: isZoomed ? 4 : 2,
                    dataEntries: [
                      RadarEntry(value: avgMasks),
                      RadarEntry(value: avgHands),
                      RadarEntry(value: avgGatherings),
                      RadarEntry(value: avgCrowds),
                      RadarEntry(value: avgStayHome),
                      RadarEntry(value: avgFear),
                    ],
                    borderWidth: 2,
                  ),
                ],
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: const BorderSide(color: Colors.transparent),
                titlePositionPercentageOffset: 0.15 / _zoomLevel,
                titleTextStyle: TextStyle(
                  color: AntiGravityTheme.textSecondaryColor,
                  fontSize: 11 / _zoomLevel,
                ),
                getTitle: (index, angle) {
                  String label = '';
                  switch (index) {
                    case 0: label = 'Masks'; break;
                    case 1: label = 'Hands'; break;
                    case 2: label = 'Gatherings'; break;
                    case 3: label = 'Crowds'; break;
                    case 4: label = 'Stay Home'; break;
                    case 5: label = 'Fear'; break;
                  }
                  if (isZoomed) {
                    double val = 0;
                    if (index == 0) val = avgMasks;
                    else if (index == 1) val = avgHands;
                    else if (index == 2) val = avgGatherings;
                    else if (index == 3) val = avgCrowds;
                    else if (index == 4) val = avgStayHome;
                    else if (index == 5) val = avgFear * 2.5; // Unscale for display
                    return RadarChartTitle(text: '$label\n${val.toStringAsFixed(1)}');
                  }
                  return RadarChartTitle(text: label);
                },
                tickCount: 4,
                ticksTextStyle: const TextStyle(color: Colors.transparent),
                gridBorderData: BorderSide(
                  color: AntiGravityTheme.textSecondaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
