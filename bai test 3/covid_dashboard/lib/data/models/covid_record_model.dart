import 'package:intl/intl.dart';
import '../../domain/entities/covid_record.dart';

class CovidRecordModel extends CovidRecord {
  const CovidRecordModel({
    required super.endDate,
    required super.region,
    required super.maskUsage,
    required super.handWashing,
    required super.avoidGatherings,
    required super.avoidCrowds,
    required super.stayHome,
    required super.fearIndex,
    required super.age,
  });

  factory CovidRecordModel.fromCsvRow(List<dynamic> row) {
    DateTime parsedDate = DateTime.now();
    try {
      final dateString = row[1].toString();
      final DateFormat format = DateFormat("dd/MM/yyyy HH:mm");
      parsedDate = format.parse(dateString);
    } catch (e) {
      parsedDate = DateTime(2020, 1, 1);
    }

    final region = row[2].toString();
    
    int fear = 0;
    try {
      fear = int.parse(row[4].toString());
    } catch (_) {}

    int age = 0;
    try {
      age = int.parse(row[74].toString());
    } catch (_) {}

    int mapBehaviorToInt(String val) {
      final clean = val.trim().toLowerCase();
      switch(clean) {
        case 'always': return 4;
        case 'frequently': return 3;
        case 'sometimes': return 2;
        case 'rarely': return 1;
        case 'not at all': return 0;
        default: return 0;
      }
    }

    final maskUsage = mapBehaviorToInt(row[13].toString());
    final handWashing = mapBehaviorToInt(row[14].toString());
    final avoidGatherings = mapBehaviorToInt(row[24].toString()); // i12_health_12
    final avoidCrowds = mapBehaviorToInt(row[25].toString());      // i12_health_13
    final stayHome = mapBehaviorToInt(row[32].toString());         // i12_health_20

    return CovidRecordModel(
      endDate: parsedDate,
      region: region,
      maskUsage: maskUsage,
      handWashing: handWashing,
      avoidGatherings: avoidGatherings,
      avoidCrowds: avoidCrowds,
      stayHome: stayHome,
      fearIndex: fear,
      age: age,
    );
  }
}
