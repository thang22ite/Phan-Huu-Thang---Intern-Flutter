class AppConfig {
  final int gridWidth;
  final int gridHeight;
  final int startX;
  final int startY;
  final double maxWeight;
  final double maxFuel;
  final int numOrders;
  final int numStations;

  const AppConfig({
    required this.gridWidth,
    required this.gridHeight,
    required this.startX,
    required this.startY,
    required this.maxWeight,
    required this.maxFuel,
    required this.numOrders,
    required this.numStations,
  });
}
