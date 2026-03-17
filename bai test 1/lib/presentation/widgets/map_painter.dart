import 'package:flutter/material.dart';
import '../../core/app_config.dart';
import '../../domain/entities/gas_station.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/point.dart';
import '../../domain/entities/step_record.dart';

class MapPainter extends CustomPainter {
  final List<Order> allOrders;
  final List<GasStation> stations;
  final List<StepRecord> history;
  final Point2D currentTruckPos;
  final AppConfig config;

  MapPainter({
    required this.allOrders,
    required this.stations,
    required this.history,
    required this.currentTruckPos,
    required this.config,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cellWidth = size.width / config.gridWidth;
    final double cellHeight = size.height / config.gridHeight;
    final double cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

    // Draw Grid
    final Paint gridPaint = Paint()
      ..color = Colors.grey.withAlpha(51)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= config.gridHeight; i++) {
      canvas.drawLine(Offset(0, i * cellSize), Offset(config.gridWidth * cellSize, i * cellSize), gridPaint);
    }
    for (int i = 0; i <= config.gridWidth; i++) {
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, config.gridHeight * cellSize), gridPaint);
    }

    // Determine order statuses
    Set<String> pickedUpIds = {};
    Set<String> droppedOffIds = {};
    for (var step in history) {
      if (step.action == StepAction.pickUp && step.refId != null) pickedUpIds.add(step.refId!);
      if (step.action == StepAction.dropOff && step.refId != null) droppedOffIds.add(step.refId!);
    }

    // Draw Stations
    final Paint stationPaint = Paint()..color = Colors.orange;
    for (var station in stations) {
      _drawCell(canvas, station.location, cellSize, stationPaint);
      _drawText(canvas, "⛽", station.location, cellSize);
    }

    // Draw Orders
    final Paint pickUpPaint = Paint()..color = Colors.blue.withAlpha(128);
    final Paint dropOffPaint = Paint()..color = Colors.green.withAlpha(128);

    for (var order in allOrders) {
      bool isPicked = pickedUpIds.contains(order.id);
      bool isDropped = droppedOffIds.contains(order.id);

      if (!isPicked) {
        _drawCell(canvas, order.pickUp, cellSize, pickUpPaint);
        _drawText(canvas, "📦", order.pickUp, cellSize);
      }
      
      if (!isDropped) {
        _drawCell(canvas, order.dropOff, cellSize, dropOffPaint);
        _drawText(canvas, "🏁", order.dropOff, cellSize);
      }
    }

    // Draw Truck Path
    if (history.length > 1) {
      final Paint pathPaint = Paint()
        ..color = Colors.purple.withAlpha(128)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      Path path = Path();
      path.moveTo(
        history.first.position.x * cellSize + cellSize / 2,
        history.first.position.y * cellSize + cellSize / 2,
      );
      for (int i = 1; i < history.length; i++) {
        path.lineTo(
          history[i].position.x * cellSize + cellSize / 2,
          history[i].position.y * cellSize + cellSize / 2,
        );
      }
      canvas.drawPath(path, pathPaint);
    }

    // Draw Truck
    final Paint truckPaint = Paint()..color = Colors.red;
    _drawCell(canvas, currentTruckPos, cellSize, truckPaint);
    _drawText(canvas, "🚚", currentTruckPos, cellSize);
  }

  void _drawCell(Canvas canvas, Point2D pt, double cellSize, Paint paint) {
    canvas.drawRect(
      Rect.fromLTWH(pt.x * cellSize, pt.y * cellSize, cellSize, cellSize),
      paint,
    );
  }

  void _drawText(Canvas canvas, String text, Point2D pt, double cellSize) {
    TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: cellSize * 1.5)), // Adjust icon size
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(
        pt.x * cellSize + (cellSize - painter.width) / 2,
        pt.y * cellSize + (cellSize - painter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.history.length != history.length || 
           oldDelegate.currentTruckPos != currentTruckPos;
  }
}
