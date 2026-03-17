import 'package:equatable/equatable.dart';

class CovidRecord extends Equatable {
  final DateTime endDate; 
  final String region;
  final int maskUsage;    
  final int handWashing;  
  final int avoidGatherings; // i12_health_12
  final int avoidCrowds;     // i12_health_13
  final int stayHome;        // i12_health_20
  final int fearIndex;    
  final int age;

  const CovidRecord({
    required this.endDate,
    required this.region,
    required this.maskUsage,
    required this.handWashing,
    required this.avoidGatherings,
    required this.avoidCrowds,
    required this.stayHome,
    required this.fearIndex,
    required this.age,
  });

  @override
  List<Object?> get props => [
    endDate, 
    region, 
    maskUsage, 
    handWashing, 
    avoidGatherings, 
    avoidCrowds, 
    stayHome, 
    fearIndex,
    age
  ];
}
