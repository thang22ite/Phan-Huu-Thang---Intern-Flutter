import 'dart:ui';

class Region {
  final String id;
  final String name;
  final String emoji;
  Offset position;

  Region({
    required this.id,
    required this.name,
    required this.emoji,
    required this.position,
  });

  Region copyWith({Offset? position}) {
    return Region(
      id: id,
      name: name,
      emoji: emoji,
      position: position ?? this.position,
    );
  }
}
