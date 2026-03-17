import 'package:equatable/equatable.dart';
import 'point.dart';

class GasStation extends Equatable {
  final String id;
  final Point2D location;

  const GasStation({required this.id, required this.location});

  @override
  List<Object?> get props => [id, location];
}
