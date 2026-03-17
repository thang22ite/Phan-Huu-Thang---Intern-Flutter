import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:covid_dashboard/core/theme/anti_gravity_theme.dart';
import 'package:covid_dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:covid_dashboard/presentation/bloc/dashboard_event.dart';
import 'package:covid_dashboard/presentation/bloc/dashboard_state.dart';
import 'package:covid_dashboard/presentation/widgets/ui/anti_gravity_container.dart';

class DateRangePickerWidget extends StatelessWidget {
  const DateRangePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoaded) {
          final startDate = state.filterStartDate ?? DateTime.now();
          final endDate = state.filterEndDate ?? DateTime.now();
          final dateFormat = DateFormat('MMM dd, yyyy');

          return AntiGravityContainer(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            borderRadius: 30,
            child: InkWell(
              onTap: () async {
                final dateRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: DateTimeRange(start: startDate, end: endDate),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AntiGravityTheme.accentColor,
                          onPrimary: Colors.black,
                          surface: AntiGravityTheme.surfaceColor,
                          onSurface: AntiGravityTheme.textPrimaryColor,
                        ),
                        scaffoldBackgroundColor: AntiGravityTheme.backgroundColor,
                      ),
                      child: child!,
                    );
                  },
                );

                if (dateRange != null && context.mounted) {
                  context.read<DashboardBloc>().add(
                        FilterByDateEvent(start: dateRange.start, end: dateRange.end),
                      );
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month, color: AntiGravityTheme.accentColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${dateFormat.format(startDate)}  -  ${dateFormat.format(endDate)}',
                    style: const TextStyle(
                      color: AntiGravityTheme.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_down, color: AntiGravityTheme.textSecondaryColor),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
