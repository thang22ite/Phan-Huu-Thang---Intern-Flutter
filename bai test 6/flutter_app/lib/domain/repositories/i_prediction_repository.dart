import '../entities/prediction_result.dart';

abstract class IPredictionRepository {
  Future<PredictionResult> getPrediction(
      String countryCode, int targetYear, List<String> models);
}
