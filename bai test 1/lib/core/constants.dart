class AppConstants {
  static const double fuelConsumptionPerCell = 0.05; // 1L / 20 cells
}

int manhattanDistance(int x1, int y1, int x2, int y2) {
  return (x1 - x2).abs() + (y1 - y2).abs();
}
