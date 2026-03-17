import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:covid_dashboard/core/theme/anti_gravity_theme.dart';
import 'package:covid_dashboard/data/datasources/remote_csv_datasource.dart';
import 'package:covid_dashboard/data/repositories/covid_repository_impl.dart';
import 'package:covid_dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:covid_dashboard/presentation/pages/dashboard_page.dart';

void main() {
  runApp(const CovidDashboardApp());
}

class CovidDashboardApp extends StatelessWidget {
  const CovidDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => RemoteCsvDataSource(),
        ),
        RepositoryProvider(
          create: (context) => CovidRepositoryImpl(
            context.read<RemoteCsvDataSource>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DashboardBloc(
              context.read<CovidRepositoryImpl>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'COVID-19 Vietnam Dashboard',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Inter', // Assumed Inter is available or fallback to system sans-serif
            colorScheme: const ColorScheme.dark(
              primary: AntiGravityTheme.accentColor,
              surface: AntiGravityTheme.backgroundColor,
            ),
            useMaterial3: true,
          ),
          home: const DashboardPage(),
        ),
      ),
    );
  }
}
