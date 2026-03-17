import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/university_repository_impl.dart';
import 'presentation/bloc/graph_bloc.dart';
import 'presentation/bloc/graph_event.dart';
import 'presentation/pages/network_graph_page.dart';

void main() {
  runApp(const UniversityNetworkApp());
}

class UniversityNetworkApp extends StatelessWidget {
  const UniversityNetworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GraphBloc(
        repository: UniversityRepositoryImpl(),
      )..add(const LoadGraph()),
      child: MaterialApp(
        title: 'Mạng lưới Đại học Việt Nam',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3B82F6),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const NetworkGraphPage(),
      ),
    );
  }
}
