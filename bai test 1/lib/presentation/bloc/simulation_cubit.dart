import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/gas_station.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/truck.dart';
import '../../domain/repositories/route_solver.dart';
import '../../core/app_config.dart';
import 'simulation_state.dart';

class SimulationCubit extends Cubit<SimulationState> {
  final RouteSolver routeSolver;
  Timer? _timer;

  SimulationCubit({required this.routeSolver}) : super(const SimulationState());

  void initializeSimulation(
    Truck initialTruck,
    List<Order> orders,
    List<GasStation> stations,
    AppConfig config,
  ) {
    _timer?.cancel();
    final path = routeSolver.solve(initialTruck, orders, stations, config);
    
    // Emit initial state with step 0 being the start pos
    emit(SimulationState(
      fullPath: path,
      currentStepIndex: 0,
      isPlaying: false,
      isFinished: path.isEmpty,
    ));
  }

  void play() {
    if (state.isFinished || state.isPlaying) return;
    
    emit(state.copyWith(isPlaying: true));
    
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (state.currentStepIndex < state.fullPath.length - 1) {
        emit(state.copyWith(
          currentStepIndex: state.currentStepIndex + 1,
        ));
      } else {
        timer.cancel();
        emit(state.copyWith(isPlaying: false, isFinished: true));
      }
    });
  }

  void pause() {
    _timer?.cancel();
    emit(state.copyWith(isPlaying: false));
  }

  void reset() {
    _timer?.cancel();
    emit(state.copyWith(
      currentStepIndex: 0,
      isPlaying: false,
      isFinished: state.fullPath.isEmpty,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
