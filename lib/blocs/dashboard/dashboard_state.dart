import 'package:equatable/equatable.dart';
import '../../models/dashboard_statistics.dart';
import '../../models/sale.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state
class DashboardLoading extends DashboardState {
  final TimePeriod? currentPeriod;
  final DateRange? currentDateRange;

  const DashboardLoading({
    this.currentPeriod,
    this.currentDateRange,
  });

  @override
  List<Object?> get props => [currentPeriod, currentDateRange];
}

/// Loaded state with dashboard statistics
class DashboardLoaded extends DashboardState {
  final DashboardStatistics statistics;
  final TimePeriod timePeriod;
  final DateRange dateRange;
  final List<Sale> latestInvoices;

  const DashboardLoaded({
    required this.statistics,
    required this.timePeriod,
    required this.dateRange,
    required this.latestInvoices,
  });

  @override
  List<Object?> get props => [
        statistics,
        timePeriod,
        dateRange,
        latestInvoices,
      ];

  DashboardLoaded copyWith({
    DashboardStatistics? statistics,
    TimePeriod? timePeriod,
    DateRange? dateRange,
    List<Sale>? latestInvoices,
  }) {
    return DashboardLoaded(
      statistics: statistics ?? this.statistics,
      timePeriod: timePeriod ?? this.timePeriod,
      dateRange: dateRange ?? this.dateRange,
      latestInvoices: latestInvoices ?? this.latestInvoices,
    );
  }
}

/// Error state
class DashboardError extends DashboardState {
  final String message;
  final TimePeriod? timePeriod;
  final DateRange? dateRange;

  const DashboardError({
    required this.message,
    this.timePeriod,
    this.dateRange,
  });

  @override
  List<Object?> get props => [message, timePeriod, dateRange];
}
