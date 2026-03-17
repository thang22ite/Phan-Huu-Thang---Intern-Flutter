import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_config.dart';
import '../../domain/entities/gas_station.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/point.dart';
import '../../domain/entities/step_record.dart';
import '../../domain/entities/truck.dart';
import '../bloc/simulation_cubit.dart';
import '../bloc/simulation_state.dart';
import '../widgets/control_panel.dart';
import '../widgets/map_painter.dart';

class HomePage extends StatefulWidget {
  final AppConfig config;

  const HomePage({super.key, required this.config});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Truck initialTruck;
  late List<Order> allOrders;
  late List<GasStation> stations;

  @override
  void initState() {
    super.initState();
    _setupScenario();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SimulationCubit>().initializeSimulation(initialTruck, allOrders, stations, widget.config);
    });
  }

  void _setupScenario() {
    initialTruck = Truck(
      position: Point2D(widget.config.startX, widget.config.startY),
      fuel: widget.config.maxFuel,
      load: 0.0,
      loadedOrders: const [],
    );

    final random = Random();
    
    // Generate Orders
    allOrders = [];
    for (int i = 0; i < widget.config.numOrders; i++) {
      Point2D pickUp;
      Point2D dropOff;
      do {
        pickUp = Point2D(random.nextInt(widget.config.gridWidth + 1), random.nextInt(widget.config.gridHeight + 1));
        dropOff = Point2D(random.nextInt(widget.config.gridWidth + 1), random.nextInt(widget.config.gridHeight + 1));
      } while (pickUp == dropOff);

      double weight = (random.nextDouble() * widget.config.maxWeight).clamp(1.0, widget.config.maxWeight);

      allOrders.add(Order(
        id: "O_${i+1}",
        pickUp: pickUp,
        dropOff: dropOff,
        weight: double.parse(weight.toStringAsFixed(1)),
      ));
    }

    // Generate Gas Stations
    stations = [];
    for (int i = 0; i < widget.config.numStations; i++) {
      Point2D location = Point2D(random.nextInt(widget.config.gridWidth + 1), random.nextInt(widget.config.gridHeight + 1));
      stations.add(GasStation(id: "GS_${i+1}", location: location));
    }
  }

  void _showSummaryDialog(BuildContext context, int totalDistance) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Simulation Completed'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Kích thước bản đồ: n = ${widget.config.gridWidth}, m = ${widget.config.gridHeight}'),
                Text('Tải trọng tối đa: W = ${widget.config.maxWeight} kg'),
                Text('Dung tích xăng: F = ${widget.config.maxFuel} lít'),
                Text('Vị trí xuất phát: start = (${widget.config.startX}, ${widget.config.startY})'),
                const SizedBox(height: 10),
                Text('Danh sách đơn hàng (${allOrders.length} đơn):', style: const TextStyle(fontWeight: FontWeight.bold)),
                ...allOrders.asMap().entries.map((entry) {
                  int idx = entry.key + 1;
                  Order o = entry.value;
                  return Text('$idx. Lấy tại (${o.pickUp.x}, ${o.pickUp.y}), w = ${o.weight} kg → Giao tại (${o.dropOff.x}, ${o.dropOff.y})');
                }),
                const SizedBox(height: 10),
                Text('Danh sách trạm xăng (${stations.length} trạm):', style: const TextStyle(fontWeight: FontWeight.bold)),
                ...stations.asMap().entries.map((entry) {
                   int idx = entry.key + 1;
                   GasStation s = entry.value;
                   return Text('$idx. (${s.location.x}, ${s.location.y})');
                }),
                const SizedBox(height: 10),
                Text('Tổng quãng đường: $totalDistance bước', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Optimization'),
        centerTitle: true,
      ),
      body: BlocListener<SimulationCubit, SimulationState>(
        listenWhen: (previous, current) => !previous.isFinished && current.isFinished && current.fullPath.isNotEmpty,
        listener: (context, state) {
          // Add small delay so the last move completes visually
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              _showSummaryDialog(context, state.totalDistanceTravelled);
            }
          });
        },
        child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      color: Colors.grey.shade50,
                    ),
                    child: BlocBuilder<SimulationCubit, SimulationState>(
                      builder: (context, state) {
                        return CustomPaint(
                          painter: MapPainter(
                            allOrders: allOrders,
                            stations: stations,
                            history: state.fullPath.isNotEmpty 
                                ? state.fullPath.sublist(0, state.currentStepIndex + 1)
                                : [],
                            currentTruckPos: state.currentPosition.x == 0 && state.currentPosition.y == 0
                                ? initialTruck.position
                                : state.currentPosition,
                            config: widget.config,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            BlocBuilder<SimulationCubit, SimulationState>(
              builder: (context, state) {
                return ControlPanel(
                  config: widget.config,
                  state: state.fullPath.isNotEmpty ? state : SimulationState(
                    fullPath: [
                      StepRecord(position: initialTruck.position, action: StepAction.move, fuel: initialTruck.fuel, load: 0)
                    ],
                  ),
                  onPlay: () => context.read<SimulationCubit>().play(),
                  onPause: () => context.read<SimulationCubit>().pause(),
                  onReset: () {
                    context.read<SimulationCubit>().reset();
                    // Optionally re-randomize or just restart with the same positions
                  },
                );
              },
            ),
          ],
        ),
      ),
      ),
    );
  }
}
