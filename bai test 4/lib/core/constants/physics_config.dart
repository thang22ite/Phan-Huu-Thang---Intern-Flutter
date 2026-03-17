/// Spring physics configuration for Anti-Gravity node animations.
class PhysicsConfig {
  PhysicsConfig._();

  /// Spring stiffness — higher = snappier return
  static const double springStiffness = 200.0;

  /// Spring damping — controls oscillation decay
  static const double springDamping = 12.0;

  /// Mass of the node for spring simulation
  static const double nodeMass = 1.0;

  /// Hover bob amplitude in pixels
  static const double bobAmplitude = 6.0;

  /// Hover bob frequency in Hz
  static const double bobFrequency = 0.5;

  /// Drag friction coefficient (0-1): lower = more slippery
  static const double dragFriction = 0.85;

  /// Scale factor when a node is pressed
  static const double pressedScale = 0.93;

  /// Duration for opacity fade transition (ms)
  static const int opacityTransitionMs = 350;
}
