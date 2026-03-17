import '../../domain/entities/covid_record.dart';
import '../../domain/repositories/i_covid_repository.dart';
import '../datasources/remote_csv_datasource.dart';

class CovidRepositoryImpl implements ICovidRepository {
  final RemoteCsvDataSource dataSource;

  CovidRepositoryImpl(this.dataSource);

  @override
  Future<List<CovidRecord>> getCovidRecords() async {
    return await dataSource.fetchRawCsvData();
  }

  @override
  Future<List<CovidRecord>> filterRecordsByDate(DateTime start, DateTime end, List<CovidRecord> cachedData) async {
    // End date is inclusive: we buffer end of day
    final endOfEndDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
    final startOfStartDay = DateTime(start.year, start.month, start.day, 0, 0, 0);

    return cachedData.where((record) {
      return record.endDate.isAfter(startOfStartDay) && record.endDate.isBefore(endOfEndDay);
    }).toList();
  }
}
