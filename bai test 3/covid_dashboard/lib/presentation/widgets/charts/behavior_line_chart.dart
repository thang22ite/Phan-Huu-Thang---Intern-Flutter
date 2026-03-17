import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:covid_dashboard/core/theme/anti_gravity_theme.dart';
import 'package:covid_dashboard/domain/entities/covid_record.dart';

class BehaviorLineChart extends StatefulWidget {
  final List<CovidRecord> data;

  const BehaviorLineChart({super.key, required this.data});

  @override
  State<BehaviorLineChart> createState() => _BehaviorLineChartState();
}

class _BehaviorLineChartState extends State<BehaviorLineChart> {
  double _zoomLevel = 1.0; // 1.0 = full view, higher = zoomed in
  double _scrollOffset = 0.0;

  // Aggregate data by day
  Map<String, List<CovidRecord>> _groupDataByDay() {
    Map<String, List<CovidRecord>> dailyGroups = {};
    for (var r in widget.data) {
      final key = DateFormat('yyyy-MM-dd').format(r.endDate);
      dailyGroups.putIfAbsent(key, () => []).add(r);
    }
    return dailyGroups;
  }

  List<FlSpot> _getSpots(Map<String, List<CovidRecord>> dailyGroups, int Function(CovidRecord) selector) {
    if (dailyGroups.isEmpty) return [];
    
    List<FlSpot> spots = [];
    int index = 0;
    final sortedKeys = dailyGroups.keys.toList()..sort();
    
    for (var key in sortedKeys) {
      final records = dailyGroups[key]!;
      final avg = records.map(selector).reduce((a, b) => a + b) / records.length;
      spots.add(FlSpot(index.toDouble(), avg));
      index++;
    }
    
    return spots;
  }

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

    final dailyGroups = _groupDataByDay();
    final maskSpots = _getSpots(dailyGroups, (r) => r.maskUsage);
    final handSpots = _getSpots(dailyGroups, (r) => r.handWashing);
    final sortedDates = dailyGroups.keys.toList()..sort();

    final maxPossibleX = (maskSpots.length - 1).toDouble();
    final visibleRange = maxPossibleX / _zoomLevel;
    
    // Ensure scroll offset stays in bounds
    if (_scrollOffset + visibleRange > maxPossibleX) {
      _scrollOffset = (maxPossibleX - visibleRange).clamp(0, maxPossibleX);
    }

    final minX = _scrollOffset;
    final maxX = _scrollOffset + visibleRange;

    // Show more details if zoom is high
    final isZoomed = _zoomLevel > 1.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Behavior Trends',
              style: TextStyle(
                color: AntiGravityTheme.textPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.zoom_in, size: 16, color: AntiGravityTheme.textSecondaryColor),
                SizedBox(
                  width: 100,
                  height: 20,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                    ),
                    child: Slider(
                      value: _zoomLevel,
                      min: 1.0,
                      max: 5.0,
                      activeColor: AntiGravityTheme.accentColor,
                      onChanged: (val) => setState(() => _zoomLevel = val),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendIndicator('Masks', AntiGravityTheme.accentColor),
            const SizedBox(width: 16),
            _buildLegendIndicator('Hands', AntiGravityTheme.secondaryAccent),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                final deltaX = details.primaryDelta! / (MediaQuery.of(context).size.width * 0.8);
                _scrollOffset = (_scrollOffset - deltaX * visibleRange).clamp(0, maxPossibleX - visibleRange);
              });
            },
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final dateStr = sortedDates[spot.x.toInt()];
                        final records = dailyGroups[dateStr]!;
                        // Get extra behavior data for tooltip
                        final avgStay = records.map((e) => e.stayHome).reduce((a, b) => a + b) / records.length;
                        final avgFear = records.map((e) => e.fearIndex).reduce((a, b) => a + b) / records.length;

                        String valStr = spot.barIndex == 0 ? 'Mask: ' : 'Hand: ';
                        if (spot.y > 3.5) valStr += 'Always';
                        else if (spot.y > 2.5) valStr += 'Freq';
                        else if (spot.y > 1.5) valStr += 'Some';
                        else valStr += 'Rare';

                        return LineTooltipItem(
                          '$dateStr\n$valStr\n🏠 Stay: ${avgStay.toStringAsFixed(1)}\n😰 Fear: ${avgFear.toStringAsFixed(1)}',
                          TextStyle(color: spot.bar.color ?? Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: isZoomed,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Color(0xFF3B3D4F),
                    strokeWidth: 0.5,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: isZoomed,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        if (value % 5 != 0) return const SizedBox.shrink(); // declutter
                        final index = value.toInt();
                        if (index < 0 || index >= sortedDates.length) return const SizedBox.shrink();
                        final date = DateTime.parse(sortedDates[index]);
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            DateFormat('MM/dd').format(date),
                            style: const TextStyle(color: AntiGravityTheme.textSecondaryColor, fontSize: 8),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return _titleText('None');
                        if (value == 2) return _titleText('Some');
                        if (value == 4) return _titleText('Always');
                        return const SizedBox.shrink();
                      },
                      reservedSize: 45,
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: minX,
                maxX: maxX,
                minY: 0,
                maxY: 4,
                lineBarsData: [
                  LineChartBarData(
                    spots: maskSpots,
                    isCurved: true,
                    color: AntiGravityTheme.accentColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: isZoomed),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AntiGravityTheme.accentColor.withOpacity(0.05),
                    ),
                  ),
                  LineChartBarData(
                    spots: handSpots,
                    isCurved: true,
                    color: AntiGravityTheme.secondaryAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: isZoomed),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AntiGravityTheme.secondaryAccent.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _titleText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AntiGravityTheme.textSecondaryColor,
        fontSize: 11,
      ),
    );
  }

  Widget _buildLegendIndicator(String name, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 8,
              )
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(
            color: AntiGravityTheme.textPrimaryColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
