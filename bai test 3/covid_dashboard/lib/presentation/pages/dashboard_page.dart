import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:covid_dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:covid_dashboard/presentation/bloc/dashboard_event.dart';
import 'package:covid_dashboard/presentation/bloc/dashboard_state.dart';
import 'package:covid_dashboard/core/theme/anti_gravity_theme.dart';
import 'package:covid_dashboard/presentation/widgets/ui/anti_gravity_container.dart';
import 'package:covid_dashboard/presentation/widgets/ui/date_range_picker_widget.dart';
import 'package:covid_dashboard/presentation/widgets/charts/behavior_line_chart.dart';
import 'package:covid_dashboard/presentation/widgets/charts/comparison_bar_chart.dart';
import 'package:covid_dashboard/presentation/widgets/charts/behavior_radar_chart.dart';
import 'package:covid_dashboard/presentation/widgets/charts/region_pie_chart.dart';
import 'package:covid_dashboard/presentation/widgets/charts/age_distribution_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch initial fetch
    context.read<DashboardBloc>().add(FetchDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to determine layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: AntiGravityTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 16,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'COVID-19 Vietnam',
                        style: TextStyle(
                          color: AntiGravityTheme.textPrimaryColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Behavioral Data Dashboard',
                        style: TextStyle(
                          color: AntiGravityTheme.accentColor.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const DateRangePickerWidget(),
                ],
              ),
              const SizedBox(height: 32),
              
              // Main Content Area
              Expanded(
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AntiGravityTheme.accentColor,
                        ),
                      );
                    } else if (state is DashboardError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      );
                    } else if (state is DashboardLoaded) {
                      return isDesktop 
                          ? _buildDesktopGrid(state) 
                          : _buildMobileList(state);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopGrid(DashboardLoaded state) {
    return Column(
      children: [
        // Top Row: Behavior Trends & Radar Profile
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: AntiGravityContainer(
                  height: double.infinity,
                  child: BehaviorLineChart(data: state.filteredData),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: AntiGravityContainer(
                  height: double.infinity,
                  child: BehaviorRadarChart(data: state.filteredData),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Middle Row: Comparison
        Expanded(
          flex: 2,
          child: AntiGravityContainer(
            height: double.infinity,
            width: double.infinity,
            child: ComparisonBarChart(data: state.filteredData),
          ),
        ),
        const SizedBox(height: 24),
        // Bottom Row: Demographics
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: AntiGravityContainer(
                  height: double.infinity,
                  child: RegionPieChart(data: state.filteredData),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: AntiGravityContainer(
                  height: double.infinity,
                  child: AgeDistributionChart(data: state.filteredData),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: AntiGravityContainer(
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.analytics_outlined, size: 24, color: AntiGravityTheme.textSecondaryColor),
                      const SizedBox(height: 4),
                      FittedBox(
                        child: Text(
                          '${state.filteredData.length} Records',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AntiGravityTheme.accentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        'in selection',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AntiGravityTheme.textSecondaryColor, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileList(DashboardLoaded state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          AntiGravityContainer(
            height: 350,
            width: double.infinity,
            child: BehaviorLineChart(data: state.filteredData),
          ),
          const SizedBox(height: 24),
          AntiGravityContainer(
            height: 350,
            width: double.infinity,
            child: BehaviorRadarChart(data: state.filteredData),
          ),
          const SizedBox(height: 24),
          AntiGravityContainer(
            height: 350,
            width: double.infinity,
            child: RegionPieChart(data: state.filteredData),
          ),
          const SizedBox(height: 24),
          AntiGravityContainer(
            height: 300,
            width: double.infinity,
            child: AgeDistributionChart(data: state.filteredData),
          ),
          const SizedBox(height: 24),
          AntiGravityContainer(
            height: 300,
            width: double.infinity,
            child: ComparisonBarChart(data: state.filteredData),
          ),
          const SizedBox(height: 24),
          AntiGravityContainer(
            height: 150,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${state.filteredData.length}',
                  style: const TextStyle(
                    color: AntiGravityTheme.accentColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Records in selected range',
                  style: TextStyle(color: AntiGravityTheme.textSecondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
