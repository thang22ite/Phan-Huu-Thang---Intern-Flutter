import '../../domain/entities/gas_station.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/point.dart';
import '../../domain/entities/step_record.dart';
import '../../core/constants.dart';
import '../../core/app_config.dart';
import '../../domain/entities/truck.dart';
import '../../domain/repositories/route_solver.dart';

class GreedyRouteSolverImpl implements RouteSolver {
  @override
  List<StepRecord> solve(
    Truck initialTruck,
    List<Order> orders,
    List<GasStation> stations,
    AppConfig config,
  ) {
    List<StepRecord> steps = [];
    Truck currentTruck = initialTruck;
    List<Order> unpickedOrders = List.from(orders);

    while (unpickedOrders.isNotEmpty || currentTruck.loadedOrders.isNotEmpty) {
      // 1. Find all valid targets
      List<Map<String, dynamic>> validTargets = [];
      
      for (var order in unpickedOrders) {
        if (currentTruck.load + order.weight <= config.maxWeight) {
          validTargets.add({
            'target': order.pickUp,
            'action': StepAction.pickUp,
            'order': order,
          });
        }
      }
      
      for (var order in currentTruck.loadedOrders) {
        validTargets.add({
          'target': order.dropOff,
          'action': StepAction.dropOff,
          'order': order,
        });
      }
      
      if (validTargets.isEmpty) {
        break; // Fallback
      }
      
      // 2. Find nearest target (Manhattan distance)
      validTargets.sort((a, b) {
        int distA = currentTruck.position.distanceTo(a['target']);
        int distB = currentTruck.position.distanceTo(b['target']);
        return distA.compareTo(distB);
      });
      
      var bestTargetMap = validTargets.first;
      Point2D bestTarget = bestTargetMap['target'];
      StepAction targetAction = bestTargetMap['action'];
      Order targetOrder = bestTargetMap['order'];
      
      // 3. Safety Gas Check
      int distToTarget = currentTruck.position.distanceTo(bestTarget);
      
      int minStationDistFromTarget = 999999;
      for (var station in stations) {
        int d = bestTarget.distanceTo(station.location);
        if (d < minStationDistFromTarget) {
          minStationDistFromTarget = d;
        }
      }
      
      double requiredFuel = (distToTarget + minStationDistFromTarget) * AppConstants.fuelConsumptionPerCell;
      
      if (currentTruck.fuel < requiredFuel) {
        // Find nearest gas station from CURRENT position
        GasStation? nearestStation;
        int minDistFromCurrent = 999999;
        for (var station in stations) {
          int d = currentTruck.position.distanceTo(station.location);
          if (d < minDistFromCurrent) {
            minDistFromCurrent = d;
            nearestStation = station;
          }
        }
        
        if (nearestStation != null) {
          // Move to nearestStation
          currentTruck = _moveTo(steps, currentTruck, nearestStation.location);
          currentTruck = currentTruck.copyWith(fuel: config.maxFuel);
          steps.add(StepRecord(
            position: currentTruck.position,
            action: StepAction.refuel,
            fuel: currentTruck.fuel,
            load: currentTruck.load,
            refId: nearestStation.id,
          ));
          continue; // Re-evaluate after refueling
        }
      }
      
      // 4. Move to bestTarget safely
      currentTruck = _moveTo(steps, currentTruck, bestTarget);
      
      // 5. Perform action
      if (targetAction == StepAction.pickUp) {
        unpickedOrders.remove(targetOrder);
        var loaded = List<Order>.from(currentTruck.loadedOrders)..add(targetOrder);
        currentTruck = currentTruck.copyWith(
          load: currentTruck.load + targetOrder.weight,
          loadedOrders: loaded,
        );
      } else if (targetAction == StepAction.dropOff) {
        var loaded = List<Order>.from(currentTruck.loadedOrders)..remove(targetOrder);
        currentTruck = currentTruck.copyWith(
          load: currentTruck.load - targetOrder.weight,
          loadedOrders: loaded,
        );
      }
      
      steps.add(StepRecord(
        position: currentTruck.position,
        action: targetAction,
        fuel: currentTruck.fuel,
        load: currentTruck.load,
        refId: targetOrder.id,
      ));
    }
    
    // 6. Return to start position
    Point2D startPosition = initialTruck.position;
    if (currentTruck.position != startPosition) {
      // Safety Gas Check for returning to start
      int distToStart = currentTruck.position.distanceTo(startPosition);
      double requiredFuel = distToStart * AppConstants.fuelConsumptionPerCell;
      
      if (currentTruck.fuel < requiredFuel) {
        GasStation? nearestStation;
        int minDistFromCurrent = 999999;
        for (var station in stations) {
          int d = currentTruck.position.distanceTo(station.location);
          if (d < minDistFromCurrent) {
            minDistFromCurrent = d;
            nearestStation = station;
          }
        }
        
        if (nearestStation != null) {
          currentTruck = _moveTo(steps, currentTruck, nearestStation.location);
          currentTruck = currentTruck.copyWith(fuel: config.maxFuel);
          steps.add(StepRecord(
            position: currentTruck.position,
            action: StepAction.refuel,
            fuel: currentTruck.fuel,
            load: currentTruck.load,
            refId: nearestStation.id,
          ));
        }
      }
      
      currentTruck = _moveTo(steps, currentTruck, startPosition);
    }
    
    return steps;
  }

  Truck _moveTo(List<StepRecord> steps, Truck truck, Point2D destination) {
    int currentX = truck.position.x;
    int currentY = truck.position.y;
    double currentFuel = truck.fuel;
    
    while (currentX != destination.x || currentY != destination.y) {
      if (currentX != destination.x) {
        currentX += (destination.x > currentX) ? 1 : -1;
      } else {
        currentY += (destination.y > currentY) ? 1 : -1;
      }
      
      currentFuel -= AppConstants.fuelConsumptionPerCell;
      if (currentFuel < 0) currentFuel = 0;
      
      Point2D nextPos = Point2D(currentX, currentY);
      steps.add(StepRecord(
        position: nextPos,
        action: StepAction.move,
        fuel: currentFuel,
        load: truck.load,
      ));
    }
    
    return truck.copyWith(position: destination, fuel: currentFuel);
  }
}
