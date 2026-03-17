import 'dart:ui';

class University {
  final String id;
  final String name;
  final String shortName;
  final String regionId;
  final int studentCount;
  final int facultyCount;
  final String type; // 'public' | 'private'
  Offset position;

  University({
    required this.id,
    required this.name,
    required this.shortName,
    required this.regionId,
    required this.studentCount,
    required this.facultyCount,
    required this.type,
    required this.position,
  });

  University copyWith({Offset? position}) {
    return University(
      id: id,
      name: name,
      shortName: shortName,
      regionId: regionId,
      studentCount: studentCount,
      facultyCount: facultyCount,
      type: type,
      position: position ?? this.position,
    );
  }
}
