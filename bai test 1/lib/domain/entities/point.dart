import 'package:equatable/equatable.dart';
import '../../core/constants.dart';

class Point2D extends Equatable {
  final int x;
  final int y;

  const Point2D(this.x, this.y);

  int distanceTo(Point2D other) {
    return manhattanDistance(x, y, other.x, other.y);
  }

  @override
  List<Object?> get props => [x, y];
}
