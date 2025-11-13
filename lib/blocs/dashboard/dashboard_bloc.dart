import 'package:flutter_bloc/flutter_bloc.dart';
import '../../database/drift_database.dart' hide Product, Sale, SaleItem;
import '../../models/dashboard_statistics.dart';
import '../../models/sale.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final AppDatabase _db = AppDatabase();

  DashboardBloc() : super(const DashboardInitial()) {
    on<LoadDashboardStatisticsEvent>(_onLoadDashboardStatistics);
    on<ChangeTimePeriodEvent>(_onChangeTimePeriod);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboardStatistics(
    LoadDashboardStatisticsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading(
      currentPeriod: event.timePeriod,
      currentDateRange: event.customDateRange,
    ));

    try {
      // Determine the date range based on the time period
      final DateRange dateRange = event.timePeriod == TimePeriod.custom
          ? event.customDateRange ?? event.timePeriod.getDateRange()
          : event.timePeriod.getDateRange();

      // Load all dashboard data in parallel
      final results = await Future.wait([
        _db.getDashboardStatistics(dateRange.start, dateRange.end),
        _db.getBestSellingProducts(dateRange.start, dateRange.end, limit: 10),
        _db.getLowStockProducts(threshold: 10, limit: 20),
        _db.getDailySalesData(dateRange.start, dateRange.end),
        _db.getCategorySalesData(dateRange.start, dateRange.end),
        _db.getSalesByDateRange(dateRange.start, dateRange.end),
      ]);

      final stats = results[0] as Map<String, dynamic>;
      final bestSellingData = results[1] as List<Map<String, dynamic>>;
      final lowStockData = results[2] as List<Map<String, dynamic>>;
      final dailySalesData = results[3] as List<Map<String, dynamic>>;
      final categorySalesData = results[4] as List<Map<String, dynamic>>;
      final allSales = results[5] as List<Sale>;

      // Convert data to model objects
      final bestSellingProducts = bestSellingData
          .map((data) => BestSellingProduct.fromJson(data))
          .toList();

      final lowStockProducts =
          lowStockData.map((data) => LowStockProduct.fromJson(data)).toList();

      final dailySales =
          dailySalesData.map((data) => DailySalesData.fromJson(data)).toList();

      final categorySales = categorySalesData
          .map((data) => CategorySalesData.fromJson(data))
          .toList();

      // Get latest 10 invoices
      final latestInvoices = allSales.take(10).toList();

      // Create dashboard statistics object
      final statistics = DashboardStatistics(
        totalProducts: stats['totalProducts'] as int,
        activeProducts: stats['activeProducts'] as int,
        totalSales: stats['totalSales'] as double,
        totalVat: stats['totalVat'] as double,
        totalCustomers: stats['totalCustomers'] as int,
        activeCustomers: stats['activeCustomers'] as int,
        totalInvoices: stats['totalInvoices'] as int,
        completedInvoices: stats['completedInvoices'] as int,
        returnedInvoices: stats['returnedInvoices'] as int,
        cancelledInvoices: stats['cancelledInvoices'] as int,
        bestSellingProducts: bestSellingProducts,
        lowStockProducts: lowStockProducts,
        dailySalesData: dailySales,
        categorySalesData: categorySales,
      );

      emit(DashboardLoaded(
        statistics: statistics,
        timePeriod: event.timePeriod,
        dateRange: dateRange,
        latestInvoices: latestInvoices,
      ));
    } catch (e) {
      emit(DashboardError(
        message: 'Failed to load dashboard statistics: ${e.toString()}',
        timePeriod: event.timePeriod,
        dateRange: event.customDateRange,
      ));
    }
  }

  Future<void> _onChangeTimePeriod(
    ChangeTimePeriodEvent event,
    Emitter<DashboardState> emit,
  ) async {
    // Reload dashboard with new time period
    add(LoadDashboardStatisticsEvent(
      timePeriod: event.timePeriod,
      customDateRange: event.customDateRange,
    ));
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    // Get current time period from state
    TimePeriod currentPeriod = TimePeriod.last7Days;
    DateRange? currentDateRange;

    if (state is DashboardLoaded) {
      final loadedState = state as DashboardLoaded;
      currentPeriod = loadedState.timePeriod;
      currentDateRange = loadedState.dateRange;
    } else if (state is DashboardLoading) {
      final loadingState = state as DashboardLoading;
      currentPeriod = loadingState.currentPeriod ?? TimePeriod.last7Days;
      currentDateRange = loadingState.currentDateRange;
    }

    // Reload with current time period
    add(LoadDashboardStatisticsEvent(
      timePeriod: currentPeriod,
      customDateRange: currentDateRange,
    ));
  }
}
