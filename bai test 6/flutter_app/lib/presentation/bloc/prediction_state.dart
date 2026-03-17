import 'package:equatable/equatable.dart';
import '../../domain/entities/prediction_result.dart';

abstract class PredictionState extends Equatable {
  const PredictionState();

  @override
  List<Object> get props => [];
}

class PredictionInitial extends PredictionState {}

class PredictionLoading extends PredictionState {}

class PredictionLoaded extends PredictionState {
  final PredictionResult result;

  const PredictionLoaded(this.result);

  @override
  List<Object> get props => [result];
}

class PredictionError extends PredictionState {
  final String message;

  const PredictionError(this.message);

  @override
  List<Object> get props => [message];
}
