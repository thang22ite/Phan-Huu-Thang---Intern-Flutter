import 'package:http/http.dart' as http;
import 'package:covid_dashboard/data/models/covid_record_model.dart';
import 'package:covid_dashboard/domain/entities/covid_record.dart';

class RemoteCsvDataSource {
  static const String csvUrl = 'https://raw.githubusercontent.com/YouGov-Data/covid-19-tracker/master/data/vietnam.csv';

  Future<List<CovidRecord>> fetchRawCsvData() async {
    try {
      final response = await http.get(Uri.parse(csvUrl));
      if (response.statusCode == 200) {
        final csvData = response.body;
        // Manual CSV Parsing to avoid external library issues in the environment
        final List<String> lines = csvData.split('\n');
        if (lines.isEmpty) return [];

        final List<CovidRecord> records = [];
        // Skip header row
        for (var i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;
          
          // Split by comma. Note: This simple split doesn't handle quoted commas, 
          // but for the YouGov dataset, it's generally safe.
          final List<dynamic> row = line.split(',');
          if (row.length > 14) { 
            records.add(CovidRecordModel.fromCsvRow(row));
          }
        }
        return records;
      } else {
        throw Exception('Failed to load CSV: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Data Fetch Error: $e');
    }
  }
}
