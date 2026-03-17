import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_prediction_repository.dart';
import 'prediction_event.dart';
import 'prediction_state.dart';

class PredictionBloc extends Bloc<PredictionEvent, PredictionState> {
  final IPredictionRepository repository;

  PredictionBloc({required this.repository}) : super(PredictionInitial()) {
    on<FetchPrediction>((event, emit) async {
      emit(PredictionLoading());
      try {
        final result = await repository.getPrediction(
          event.countryCode,
          event.targetYear,
          event.selectedModels,
        );
        emit(PredictionLoaded(result));
      } catch (e) {
        emit(PredictionError(e.toString()));
      }
    });
  }
}
