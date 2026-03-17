import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_covid_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ICovidRepository repository;

  DashboardBloc(this.repository) : super(DashboardInitial()) {
    on<FetchDataEvent>(_onFetchData);
    on<FilterByDateEvent>(_onFilterByDate);
  }

  Future<void> _onFetchData(FetchDataEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final records = await repository.getCovidRecords();
      if (records.isEmpty) {
        emit(const DashboardError('No data available from the source.'));
        return;
      }
      // Sort logic
      records.sort((a, b) => a.endDate.compareTo(b.endDate));

      // Initial range defaults to min/max
      final minDate = records.first.endDate;
      final maxDate = records.last.endDate;

      emit(DashboardLoaded(
        allData: records,
        filteredData: records,
        filterStartDate: minDate,
        filterEndDate: maxDate,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onFilterByDate(FilterByDateEvent event, Emitter<DashboardState> emit) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      try {
        final filteredList = await repository.filterRecordsByDate(
          event.start,
          event.end,
          currentState.allData,
        );
        emit(currentState.copyWith(
          filteredData: filteredList,
          filterStartDate: event.start,
          filterEndDate: event.end,
        ));
      } catch (e) {
        // Handle filter error if any
      }
    }
  }
}
