import 'package:equatable/equatable.dart';

abstract class PredictionEvent extends Equatable {
  const PredictionEvent();

  @override
  List<Object> get props => [];
}

class FetchPrediction extends PredictionEvent {
  final String countryCode;
  final int targetYear;
  final List<String> selectedModels;

  const FetchPrediction(this.countryCode, this.targetYear, this.selectedModels);

  @override
  List<Object> get props => [countryCode, targetYear, selectedModels];
}
