import 'package:equatable/equatable.dart';
import 'point.dart';
import 'order.dart';

class Truck extends Equatable {
  final Point2D position;
  final double fuel;
  final double load;
  final List<Order> loadedOrders;

  const Truck({
    required this.position,
    required this.fuel,
    required this.load,
    required this.loadedOrders,
  });

  Truck copyWith({
    Point2D? position,
    double? fuel,
    double? load,
    List<Order>? loadedOrders,
  }) {
    return Truck(
      position: position ?? this.position,
      fuel: fuel ?? this.fuel,
      load: load ?? this.load,
      loadedOrders: loadedOrders ?? this.loadedOrders,
    );
  }

  @override
  List<Object?> get props => [position, fuel, load, loadedOrders];
}
