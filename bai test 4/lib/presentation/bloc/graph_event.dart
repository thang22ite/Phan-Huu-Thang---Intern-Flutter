import 'package:equatable/equatable.dart';
import 'dart:ui';

abstract class GraphEvent extends Equatable {
  const GraphEvent();

  @override
  List<Object?> get props => [];
}

class LoadGraph extends GraphEvent {
  const LoadGraph();
}

class SelectNode extends GraphEvent {
  final String? nodeId; // null to deselect
  const SelectNode(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}

class FilterByRegion extends GraphEvent {
  final String? regionId; // null = show all
  const FilterByRegion(this.regionId);

  @override
  List<Object?> get props => [regionId];
}

class UpdateNodePosition extends GraphEvent {
  final String nodeId;
  final Offset position;
  final bool isRegion;

  const UpdateNodePosition({
    required this.nodeId,
    required this.position,
    this.isRegion = false,
  });

  @override
  List<Object?> get props => [nodeId, position, isRegion];
}
