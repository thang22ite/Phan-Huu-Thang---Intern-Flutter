import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/prediction_bloc.dart';
import '../bloc/prediction_event.dart';
import '../bloc/prediction_state.dart';
import '../../domain/entities/prediction_result.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  String selectedCountry = 'VN';
  int targetYear = 2030;
  List<String> selectedModels = ['Linear Regression'];
  
  final Map<String, String> countryMap = {
    'VN': 'Vietnam', 'US': 'United States', 'CN': 'China', 'IN': 'India', 
    'ID': 'Indonesia', 'PK': 'Pakistan', 'BR': 'Brazil', 'NG': 'Nigeria', 
    'BD': 'Bangladesh', 'RU': 'Russia', 'MX': 'Mexico', 'JP': 'Japan', 
    'ET': 'Ethiopia', 'PH': 'Philippines', 'EG': 'Egypt', 'CD': 'DR Congo', 
    'TR': 'Turkey', 'IR': 'Iran', 'DE': 'Germany', 'TH': 'Thailand', 
    'GB': 'United Kingdom', 'FR': 'France', 'IT': 'Italy', 'TZ': 'Tanzania', 
    'ZA': 'South Africa'
  };

  final List<int> years = [2025, 2030, 2035, 2040, 2050];
  final List<String> models = [
    'Linear Regression',
    'Random Forest',
    'Gradient Boosting'
  ];

  void _submitPrediction() {
    if (selectedModels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one model')),
      );
      return;
    }
    context.read<PredictionBloc>().add(
      FetchPrediction(selectedCountry, targetYear, selectedModels)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Population Predictor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _buildFilterPanel(),
          Expanded(
            child: BlocBuilder<PredictionBloc, PredictionState>(
              builder: (context, state) {
                if (state is PredictionInitial) {
                  return const Center(child: Text('Please select options to predict.'));
                } else if (state is PredictionLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PredictionLoaded) {
                  return _buildDashboard(state.result);
                } else if (state is PredictionError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DropdownButton<String>(
                  value: selectedCountry,
                  underline: Container(height: 2, color: Colors.deepPurple),
                  items: countryMap.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                  onChanged: (val) => setState(() => selectedCountry = val!),
                ),
                DropdownButton<int>(
                  value: targetYear,
                  underline: Container(height: 2, color: Colors.deepPurple),
                  items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                  onChanged: (val) => setState(() => targetYear = val!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: models.map((model) {
                return FilterChip(
                  label: Text(model),
                  selected: selectedModels.contains(model),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedModels.add(model);
                      } else {
                        selectedModels.remove(model);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submitPrediction,
              icon: const Icon(Icons.analytics),
              label: const Text('Predict Population'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(PredictionResult result) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 12.0, top: 24.0, bottom: 12.0),
            child: LineChart(
              LineChartData(
                lineBarsData: _buildChartLines(result),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text("Year"),
                    sideTitles: SideTitles(
                      showTitles: true, 
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                        );
                      }
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text("Population"),
                    sideTitles: SideTitles(
                      showTitles: true, 
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        // Format large numbers (e.g., 90M)
                        String formatted = (value / 1000000).toStringAsFixed(0) + 'M';
                        return Text(formatted, style: const TextStyle(fontSize: 10));
                      }
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                clipData: const FlClipData.none(), // Important to show tooltips near edges
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => Colors.blueGrey.withOpacity(0.9),
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 10,
                    fitInsideHorizontally: true, // This keeps the tooltip inside the chart area
                    fitInsideVertically: true,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.x.toInt()}: ${(spot.y / 1000000).toStringAsFixed(2)}M',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Card(
            margin: const EdgeInsets.all(12),
            child: _buildMetricsTable(result.metrics),
          )
        )
      ],
    );
  }

  List<LineChartBarData> _buildChartLines(PredictionResult result) {
    List<LineChartBarData> bars = [];
    
    // 1. Historical Line
    List<FlSpot> histSpots = [];
    for(int i = 0; i < result.historicalYears.length; i++) {
        histSpots.add(FlSpot(
          result.historicalYears[i].toDouble(), 
          result.historicalPopulations[i].toDouble()
        ));
    }
    bars.add(LineChartBarData(
      spots: histSpots, 
      color: Colors.black, 
      isCurved: true,
      barWidth: 3,
      dotData: const FlDotData(show: false)
    ));

    // Get last point of history to connect the lines smoothly
    FlSpot? lastHistSpot;
    if (histSpots.isNotEmpty) {
      lastHistSpot = histSpots.last;
    }

    // 2. Future Lines for each Model
    final colors = [Colors.blue, Colors.red, Colors.green];
    int colorIdx = 0;
    
    result.predictions.forEach((modelName, predictedPops) {
      List<FlSpot> predSpots = [];
      if (lastHistSpot != null) {
        predSpots.add(lastHistSpot);
      }
      
      for(int i=0; i < result.futureYears.length; i++) {
        predSpots.add(FlSpot(
          result.futureYears[i].toDouble(), 
          predictedPops[i].toDouble()
        ));
      }
      
      bars.add(LineChartBarData(
        spots: predSpots, 
        color: colors[colorIdx % colors.length], 
        isCurved: true,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        dashArray: [5, 5] // Dashed line for predictions
      ));
      colorIdx++;
    });

    return bars;
  }

  Widget _buildMetricsTable(Map<String, dynamic> metrics) {
    if (metrics.isEmpty) return const Center(child: Text("No metrics available"));

    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Models Accuracy Evaluation (Train data)", 
            textAlign: TextAlign.center, 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
          ),
        ),
        DataTable(
          headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade100),
          columns: const [
            DataColumn(label: Text('Model', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('RMSE', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('MAE', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: metrics.entries.map((e) {
            double rmse = (e.value['rmse'] as num).toDouble();
            double mae = (e.value['mae'] as num).toDouble();
            return DataRow(cells: [
              DataCell(Text(e.key)),
              DataCell(Text((rmse / 1000000).toStringAsFixed(3) + 'M', style: const TextStyle(color: Colors.red))),
              DataCell(Text((mae / 1000000).toStringAsFixed(3) + 'M', style: const TextStyle(color: Colors.orange))),
            ]);
          }).toList(),
        )
      ],
    );
  }
}
