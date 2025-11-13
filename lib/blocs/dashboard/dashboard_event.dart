import 'package:equatable/equatable.dart';
import '../../models/dashboard_statistics.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load dashboard statistics for a given time period
class LoadDashboardStatisticsEvent extends DashboardEvent {
  final TimePeriod timePeriod;
  final DateRange? customDateRange;

  const LoadDashboardStatisticsEvent({
    required this.timePeriod,
    this.customDateRange,
  });

  @override
  List<Object?> get props => [timePeriod, customDateRange];
}

/// Event to change the time period filter
class ChangeTimePeriodEvent extends DashboardEvent {
  final TimePeriod timePeriod;
  final DateRange? customDateRange;

  const ChangeTimePeriodEvent({
    required this.timePeriod,
    this.customDateRange,
  });

  @override
  List<Object?> get props => [timePeriod, customDateRange];
}

/// Event to refresh dashboard data
class RefreshDashboardEvent extends DashboardEvent {
  const RefreshDashboardEvent();
}
