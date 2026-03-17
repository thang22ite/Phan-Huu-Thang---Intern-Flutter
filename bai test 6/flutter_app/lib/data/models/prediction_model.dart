import '../../domain/entities/prediction_result.dart';

class PredictionModel extends PredictionResult {
  const PredictionModel({
    required String countryCode,
    required List<int> historicalYears,
    required List<int> historicalPopulations,
    required List<int> futureYears,
    required Map<String, List<int>> predictions,
    required Map<String, dynamic> metrics,
  }) : super(
          countryCode: countryCode,
          historicalYears: historicalYears,
          historicalPopulations: historicalPopulations,
          futureYears: futureYears,
          predictions: predictions,
          metrics: metrics,
        );

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    // Parse predictions map
    final predMap = json['predictions'] as Map<String, dynamic>;
    final Map<String, List<int>> parsedPredictions = {};
    predMap.forEach((key, value) {
      if (value is List) {
        parsedPredictions[key] = value.map((e) => e as int).toList();
      }
    });

    return PredictionModel(
      countryCode: json['country_code'],
      historicalYears: List<int>.from(json['historical_years']),
      historicalPopulations: List<int>.from(json['historical_populations']),
      futureYears: List<int>.from(json['future_years']),
      predictions: parsedPredictions,
      metrics: json['metrics'],
    );
  }
}
