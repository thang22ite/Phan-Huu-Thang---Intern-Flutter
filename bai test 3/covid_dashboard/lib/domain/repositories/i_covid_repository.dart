import '../entities/covid_record.dart';

abstract class ICovidRepository {
  /// Fetches raw data from CSV and returns parsed records
  Future<List<CovidRecord>> getCovidRecords();

  /// Filters data between date ranges. Expects to be done primarily in-memory/Bloc
  Future<List<CovidRecord>> filterRecordsByDate(DateTime start, DateTime end, List<CovidRecord> cachedData);
}
