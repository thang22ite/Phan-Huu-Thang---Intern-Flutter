import 'package:equatable/equatable.dart';
import '../../domain/entities/region.dart';
import '../../domain/entities/university.dart';

abstract class GraphState extends Equatable {
  const GraphState();

  @override
  List<Object?> get props => [];
}

class GraphInitial extends GraphState {
  const GraphInitial();
}

class GraphLoading extends GraphState {
  const GraphLoading();
}

class GraphLoaded extends GraphState {
  final List<University> universities;
  final List<Region> regions;
  final String? selectedNodeId;
  final bool selectedIsRegion;
  final String? activeFilterRegionId; // null = all

  const GraphLoaded({
    required this.universities,
    required this.regions,
    this.selectedNodeId,
    this.selectedIsRegion = false,
    this.activeFilterRegionId,
  });

  GraphLoaded copyWith({
    List<University>? universities,
    List<Region>? regions,
    String? selectedNodeId,
    bool clearSelection = false,
    bool selectedIsRegion = false,
    String? activeFilterRegionId,
    bool clearFilter = false,
  }) {
    return GraphLoaded(
      universities: universities ?? this.universities,
      regions: regions ?? this.regions,
      selectedNodeId: clearSelection ? null : (selectedNodeId ?? this.selectedNodeId),
      selectedIsRegion: clearSelection ? false : selectedIsRegion,
      activeFilterRegionId:
          clearFilter ? null : (activeFilterRegionId ?? this.activeFilterRegionId),
    );
  }

  /// Returns opacity for a university based on active region filter.
  double opacityForUniversity(University u) {
    if (activeFilterRegionId == null) return 1.0;
    return u.regionId == activeFilterRegionId ? 1.0 : 0.18;
  }

  /// Returns opacity for a region node based on active filter.
  double opacityForRegion(Region r) {
    if (activeFilterRegionId == null) return 1.0;
    return r.id == activeFilterRegionId ? 1.0 : 0.18;
  }

  @override
  List<Object?> get props => [
        universities,
        regions,
        selectedNodeId,
        selectedIsRegion,
        activeFilterRegionId,
      ];
}

class GraphError extends GraphState {
  final String message;
  const GraphError(this.message);

  @override
  List<Object?> get props => [message];
}
