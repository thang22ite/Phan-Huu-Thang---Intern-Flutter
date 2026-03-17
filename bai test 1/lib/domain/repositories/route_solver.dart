import '../entities/gas_station.dart';
import '../entities/order.dart';
import '../entities/step_record.dart';
import '../entities/truck.dart';
import '../../core/app_config.dart';

abstract class RouteSolver {
  List<StepRecord> solve(
    Truck initialTruck,
    List<Order> orders,
    List<GasStation> stations,
    AppConfig config,
  );
}
