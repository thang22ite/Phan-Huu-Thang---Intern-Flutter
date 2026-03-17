import 'package:equatable/equatable.dart';
import '../../domain/entities/step_record.dart';
import '../../domain/entities/point.dart';

class SimulationState extends Equatable {
  final List<StepRecord> fullPath;
  final int currentStepIndex;
  final bool isPlaying;
  final bool isFinished;

  const SimulationState({
    this.fullPath = const [],
    this.currentStepIndex = 0,
    this.isPlaying = false,
    this.isFinished = false,
  });

  SimulationState copyWith({
    List<StepRecord>? fullPath,
    int? currentStepIndex,
    bool? isPlaying,
    bool? isFinished,
  }) {
    return SimulationState(
      fullPath: fullPath ?? this.fullPath,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  StepRecord? get currentStep => 
      (fullPath.isNotEmpty && currentStepIndex < fullPath.length) 
          ? fullPath[currentStepIndex] : null;

  Point2D get currentPosition => currentStep?.position ?? const Point2D(0, 0);
  double get currentFuel => currentStep?.fuel ?? 0.0;
  double get currentLoad => currentStep?.load ?? 0.0;
  
  // A move is a cell movement, total distance travelled corresponds to currentStepIndex
  int get totalDistanceTravelled {
    int dist = 0;
    for (int i = 0; i <= currentStepIndex && i < fullPath.length; i++) {
      if (fullPath[i].action == StepAction.move) {
        dist++;
      }
    }
    return dist;
  }

  @override
  List<Object?> get props => [fullPath, currentStepIndex, isPlaying, isFinished];
}
