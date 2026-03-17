import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/greedy_route_solver_impl.dart';
import 'presentation/bloc/simulation_cubit.dart';
import 'presentation/pages/setup_page.dart';

void main() {
  final routeSolver = GreedyRouteSolverImpl();
  runApp(MyApp(routeSolver: routeSolver));
}

class MyApp extends StatelessWidget {
  final GreedyRouteSolverImpl routeSolver;

  const MyApp({super.key, required this.routeSolver});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SimulationCubit(routeSolver: routeSolver),
      child: MaterialApp(
        title: 'Delivery Route Optimization',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SetupPage(),
      ),
    );
  }
}
