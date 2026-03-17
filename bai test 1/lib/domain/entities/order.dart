import 'package:equatable/equatable.dart';
import 'point.dart';

class Order extends Equatable {
  final String id;
  final Point2D pickUp;
  final Point2D dropOff;
  final double weight;

  const Order({
    required this.id,
    required this.pickUp,
    required this.dropOff,
    required this.weight,
  });

  @override
  List<Object?> get props => [id, pickUp, dropOff, weight];
}
