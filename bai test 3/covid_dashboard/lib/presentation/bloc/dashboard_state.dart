import 'package:equatable/equatable.dart';
import '../../domain/entities/covid_record.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<CovidRecord> allData;
  final List<CovidRecord> filteredData;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  const DashboardLoaded({
    required this.allData,
    required this.filteredData,
    this.filterStartDate,
    this.filterEndDate,
  });

  @override
  List<Object?> get props => [allData, filteredData, filterStartDate, filterEndDate];

  DashboardLoaded copyWith({
    List<CovidRecord>? allData,
    List<CovidRecord>? filteredData,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
  }) {
    return DashboardLoaded(
      allData: allData ?? this.allData,
      filteredData: filteredData ?? this.filteredData,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
