import 'package:equatable/equatable.dart';

/// Represents the overall dashboard statistics for a given time period
class DashboardStatistics extends Equatable {
  final int totalProducts;
  final int activeProducts;
  final double totalSales;
  final double totalVat;
  final int totalCustomers;
  final int activeCustomers;
  final int totalInvoices;
  final int completedInvoices;
  final int returnedInvoices;
  final int cancelledInvoices;
  final List<BestSellingProduct> bestSellingProducts;
  final List<LowStockProduct> lowStockProducts;
  final List<DailySalesData> dailySalesData;
  final List<CategorySalesData> categorySalesData;

  const DashboardStatistics({
    required this.totalProducts,
    required this.activeProducts,
    required this.totalSales,
    required this.totalVat,
    required this.totalCustomers,
    required this.activeCustomers,
    required this.totalInvoices,
    required this.completedInvoices,
    required this.returnedInvoices,
    required this.cancelledInvoices,
    required this.bestSellingProducts,
    required this.lowStockProducts,
    required this.dailySalesData,
    required this.categorySalesData,
  });

  @override
  List<Object?> get props => [
        totalProducts,
        activeProducts,
        totalSales,
        totalVat,
        totalCustomers,
        activeCustomers,
        totalInvoices,
        completedInvoices,
        returnedInvoices,
        cancelledInvoices,
        bestSellingProducts,
        lowStockProducts,
        dailySalesData,
        categorySalesData,
      ];

  DashboardStatistics copyWith({
    int? totalProducts,
    int? activeProducts,
    double? totalSales,
    double? totalVat,
    int? totalCustomers,
    int? activeCustomers,
    int? totalInvoices,
    int? completedInvoices,
    int? returnedInvoices,
    int? cancelledInvoices,
    List<BestSellingProduct>? bestSellingProducts,
    List<LowStockProduct>? lowStockProducts,
    List<DailySalesData>? dailySalesData,
    List<CategorySalesData>? categorySalesData,
  }) {
    return DashboardStatistics(
      totalProducts: totalProducts ?? this.totalProducts,
      activeProducts: activeProducts ?? this.activeProducts,
      totalSales: totalSales ?? this.totalSales,
      totalVat: totalVat ?? this.totalVat,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      activeCustomers: activeCustomers ?? this.activeCustomers,
      totalInvoices: totalInvoices ?? this.totalInvoices,
      completedInvoices: completedInvoices ?? this.completedInvoices,
      returnedInvoices: returnedInvoices ?? this.returnedInvoices,
      cancelledInvoices: cancelledInvoices ?? this.cancelledInvoices,
      bestSellingProducts: bestSellingProducts ?? this.bestSellingProducts,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      dailySalesData: dailySalesData ?? this.dailySalesData,
      categorySalesData: categorySalesData ?? this.categorySalesData,
    );
  }

  factory DashboardStatistics.empty() {
    return const DashboardStatistics(
      totalProducts: 0,
      activeProducts: 0,
      totalSales: 0.0,
      totalVat: 0.0,
      totalCustomers: 0,
      activeCustomers: 0,
      totalInvoices: 0,
      completedInvoices: 0,
      returnedInvoices: 0,
      cancelledInvoices: 0,
      bestSellingProducts: [],
      lowStockProducts: [],
      dailySalesData: [],
      categorySalesData: [],
    );
  }
}

/// Represents a best-selling product with sales statistics
class BestSellingProduct extends Equatable {
  final String productId;
  final String productName;
  final String? productImage;
  final double totalQuantitySold;
  final double totalRevenue;
  final int transactionCount;
  final String? category;

  const BestSellingProduct({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.totalQuantitySold,
    required this.totalRevenue,
    required this.transactionCount,
    this.category,
  });

  @override
  List<Object?> get props => [
        productId,
        productName,
        productImage,
        totalQuantitySold,
        totalRevenue,
        transactionCount,
        category,
      ];

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'totalQuantitySold': totalQuantitySold,
      'totalRevenue': totalRevenue,
      'transactionCount': transactionCount,
      'category': category,
    };
  }

  factory BestSellingProduct.fromJson(Map<String, dynamic> json) {
    return BestSellingProduct(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String?,
      totalQuantitySold: (json['totalQuantitySold'] as num).toDouble(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
      category: json['category'] as String?,
    );
  }
}

/// Represents a product with low stock
class LowStockProduct extends Equatable {
  final String productId;
  final String productName;
  final String? productImage;
  final double currentQuantity;
  final double? reorderLevel;
  final String? category;
  final bool isActive;

  const LowStockProduct({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.currentQuantity,
    this.reorderLevel,
    this.category,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        productId,
        productName,
        productImage,
        currentQuantity,
        reorderLevel,
        category,
        isActive,
      ];

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'currentQuantity': currentQuantity,
      'reorderLevel': reorderLevel,
      'category': category,
      'isActive': isActive,
    };
  }

  factory LowStockProduct.fromJson(Map<String, dynamic> json) {
    return LowStockProduct(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String?,
      currentQuantity: (json['currentQuantity'] as num).toDouble(),
      reorderLevel: json['reorderLevel'] != null
          ? (json['reorderLevel'] as num).toDouble()
          : null,
      category: json['category'] as String?,
      isActive: json['isActive'] as bool,
    );
  }
}

/// Represents daily sales data for charting
class DailySalesData extends Equatable {
  final DateTime date;
  final double totalSales;
  final double totalVat;
  final int invoiceCount;

  const DailySalesData({
    required this.date,
    required this.totalSales,
    required this.totalVat,
    required this.invoiceCount,
  });

  @override
  List<Object?> get props => [date, totalSales, totalVat, invoiceCount];

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalSales': totalSales,
      'totalVat': totalVat,
      'invoiceCount': invoiceCount,
    };
  }

  factory DailySalesData.fromJson(Map<String, dynamic> json) {
    return DailySalesData(
      date: DateTime.parse(json['date'] as String),
      totalSales: (json['totalSales'] as num).toDouble(),
      totalVat: (json['totalVat'] as num).toDouble(),
      invoiceCount: json['invoiceCount'] as int,
    );
  }
}

/// Represents sales data by category for pie charts
class CategorySalesData extends Equatable {
  final String categoryName;
  final double totalRevenue;
  final int productCount;
  final int transactionCount;

  const CategorySalesData({
    required this.categoryName,
    required this.totalRevenue,
    required this.productCount,
    required this.transactionCount,
  });

  @override
  List<Object?> get props =>
      [categoryName, totalRevenue, productCount, transactionCount];

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'totalRevenue': totalRevenue,
      'productCount': productCount,
      'transactionCount': transactionCount,
    };
  }

  factory CategorySalesData.fromJson(Map<String, dynamic> json) {
    return CategorySalesData(
      categoryName: json['categoryName'] as String,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      productCount: json['productCount'] as int,
      transactionCount: json['transactionCount'] as int,
    );
  }
}

/// Enum for time period selection
enum TimePeriod {
  last7Days,
  lastMonth,
  lastYear,
  custom,
}

extension TimePeriodExtension on TimePeriod {
  String get displayName {
    switch (this) {
      case TimePeriod.last7Days:
        return 'Last 7 Days';
      case TimePeriod.lastMonth:
        return 'Last Month';
      case TimePeriod.lastYear:
        return 'Last Year';
      case TimePeriod.custom:
        return 'Custom Period';
    }
  }

  /// Calculate the date range for the given time period
  DateRange getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case TimePeriod.last7Days:
        return DateRange(
          start: today.subtract(const Duration(days: 6)),
          end: today.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1)),
        );
      case TimePeriod.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final thisMonth = DateTime(now.year, now.month, 1);
        return DateRange(
          start: lastMonth,
          end: thisMonth.subtract(const Duration(microseconds: 1)),
        );
      case TimePeriod.lastYear:
        final lastYear = DateTime(now.year - 1, 1, 1);
        final thisYear = DateTime(now.year, 1, 1);
        return DateRange(
          start: lastYear,
          end: thisYear.subtract(const Duration(microseconds: 1)),
        );
      case TimePeriod.custom:
        // For custom, we'll use last 30 days as default
        return DateRange(
          start: today.subtract(const Duration(days: 29)),
          end: today.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1)),
        );
    }
  }
}

/// Represents a date range for filtering
class DateRange extends Equatable {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  @override
  List<Object?> get props => [start, end];

  DateRange copyWith({
    DateTime? start,
    DateTime? end,
  }) {
    return DateRange(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  /// Format the date range for display
  String format() {
    final startStr =
        '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}';
    final endStr =
        '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';
    return '$startStr - $endStr';
  }
}
