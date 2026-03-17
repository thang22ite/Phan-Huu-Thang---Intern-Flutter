import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/university.dart';
import '../../domain/entities/region.dart';
import '../../domain/repositories/i_university_repository.dart';
import 'graph_event.dart';
import 'graph_state.dart';

class GraphBloc extends Bloc<GraphEvent, GraphState> {
  final IUniversityRepository _repository;

  GraphBloc({required IUniversityRepository repository})
      : _repository = repository,
        super(const GraphInitial()) {
    on<LoadGraph>(_onLoadGraph);
    on<SelectNode>(_onSelectNode);
    on<FilterByRegion>(_onFilterByRegion);
    on<UpdateNodePosition>(_onUpdateNodePosition);
  }

  Future<void> _onLoadGraph(
    LoadGraph event,
    Emitter<GraphState> emit,
  ) async {
    emit(const GraphLoading());
    try {
      final universities = await _repository.getUniversities();
      final regions = await _repository.getRegions();
      emit(GraphLoaded(universities: universities, regions: regions));
    } catch (e) {
      emit(GraphError(e.toString()));
    }
  }

  void _onSelectNode(SelectNode event, Emitter<GraphState> emit) {
    if (state is GraphLoaded) {
      final current = state as GraphLoaded;
      // Deselect if tapping same node
      if (current.selectedNodeId == event.nodeId) {
        emit(current.copyWith(clearSelection: true));
      } else {
        emit(current.copyWith(
          selectedNodeId: event.nodeId,
          selectedIsRegion: false,
        ));
      }
    }
  }

  void _onFilterByRegion(FilterByRegion event, Emitter<GraphState> emit) {
    if (state is GraphLoaded) {
      final current = state as GraphLoaded;
      // Toggle off if same region selected
      if (current.activeFilterRegionId == event.regionId) {
        emit(current.copyWith(clearFilter: true));
      } else {
        emit(current.copyWith(activeFilterRegionId: event.regionId));
      }
    }
  }

  void _onUpdateNodePosition(
    UpdateNodePosition event,
    Emitter<GraphState> emit,
  ) {
    if (state is GraphLoaded) {
      final current = state as GraphLoaded;

      if (event.isRegion) {
        final updatedRegions = current.regions.map((r) {
          if (r.id == event.nodeId) {
            return r.copyWith(position: event.position);
          }
          return r;
        }).toList();
        emit(current.copyWith(regions: updatedRegions));
      } else {
        final updatedUniversities = current.universities.map((u) {
          if (u.id == event.nodeId) {
            return u.copyWith(position: event.position);
          }
          return u;
        }).toList();
        emit(current.copyWith(universities: updatedUniversities));
      }
    }
  }
}
