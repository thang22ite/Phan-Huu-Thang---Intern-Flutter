import 'package:equatable/equatable.dart';

class PredictionResult extends Equatable {
  final String countryCode;
  final List<int> historicalYears;
  final List<int> historicalPopulations;
  final List<int> futureYears;
  final Map<String, List<int>> predictions;
  final Map<String, dynamic> metrics; // Model -> {rmse, mae}

  const PredictionResult({
    required this.countryCode,
    required this.historicalYears,
    required this.historicalPopulations,
    required this.futureYears,
    required this.predictions,
    required this.metrics,
  });

  @override
  List<Object?> get props => [
        countryCode,
        historicalYears,
        historicalPopulations,
        futureYears,
        predictions,
        metrics,
      ];
}
