import 'package:equatable/equatable.dart';
import 'point.dart';

enum StepAction { pickUp, dropOff, refuel, move }

class StepRecord extends Equatable {
  final Point2D position;
  final StepAction action;
  final double fuel;
  final double load;
  final String? refId; // orderId or gasStationId

  const StepRecord({
    required this.position,
    required this.action,
    required this.fuel,
    required this.load,
    this.refId,
  });

  @override
  List<Object?> get props => [position, action, fuel, load, refId];
}
