import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchDataEvent extends DashboardEvent {}

class FilterByDateEvent extends DashboardEvent {
  final DateTime start;
  final DateTime end;

  const FilterByDateEvent({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];
}
