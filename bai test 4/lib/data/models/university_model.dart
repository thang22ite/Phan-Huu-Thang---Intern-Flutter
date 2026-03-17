import 'dart:ui';
import '../../domain/entities/university.dart';

class UniversityModel extends University {
  UniversityModel({
    required super.id,
    required super.name,
    required super.shortName,
    required super.regionId,
    required super.studentCount,
    required super.facultyCount,
    required super.type,
    required super.position,
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      regionId: json['regionId'] as String,
      studentCount: json['studentCount'] as int,
      facultyCount: json['facultyCount'] as int,
      type: json['type'] as String,
      position: Offset(
        (json['posX'] as num).toDouble(),
        (json['posY'] as num).toDouble(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shortName': shortName,
        'regionId': regionId,
        'studentCount': studentCount,
        'facultyCount': facultyCount,
        'type': type,
        'posX': position.dx,
        'posY': position.dy,
      };
}
