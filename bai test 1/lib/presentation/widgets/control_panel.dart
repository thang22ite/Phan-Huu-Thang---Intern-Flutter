import 'package:flutter/material.dart';
import '../../core/app_config.dart';
import '../bloc/simulation_state.dart';

class ControlPanel extends StatelessWidget {
  final SimulationState state;
  final AppConfig config;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onReset;

  const ControlPanel({
    super.key,
    required this.state,
    required this.config,
    required this.onPlay,
    required this.onPause,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat("Fuel", "${state.currentFuel.toStringAsFixed(2)} L", state.currentFuel / config.maxFuel, Colors.orange),
              _buildStat("Load", "${state.currentLoad.toStringAsFixed(1)} kg", state.currentLoad / config.maxWeight, Colors.blue),
              _buildStatText("Distance", "${state.totalDistanceTravelled} cells"),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onReset,
                color: Colors.grey,
                iconSize: 32,
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                onPressed: state.isPlaying ? onPause : onPlay,
                backgroundColor: state.isPlaying ? Colors.red : Colors.green,
                child: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, double progress, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.withAlpha(51),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildStatText(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12), // Align with progress bars
      ],
    );
  }
}
