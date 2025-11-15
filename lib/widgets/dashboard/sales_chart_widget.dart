import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_ui_design/liquid_glass_ui_design.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../../models/dashboard_statistics.dart';

/// Widget to display sales chart (line chart for daily sales)
class SalesChartWidget extends StatefulWidget {
  final List<DailySalesData> dailySalesData;
  final bool isLoading;

  const SalesChartWidget({
    super.key,
    required this.dailySalesData,
    this.isLoading = false,
  });

  @override
  State<SalesChartWidget> createState() => _SalesChartWidgetState();
}

class _SalesChartWidgetState extends State<SalesChartWidget> {
  bool showVat = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return LiquidCard(
      elevation: 3,
      blur: 18,
      opacity: 0.15,
      borderRadius: 12,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.show_chart,
                    color: theme.colorScheme.primary,
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    l10n.salesTrend,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(l10n.salesLabel),
                    icon: const Icon(Icons.attach_money, size: 16),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(l10n.vatLabel),
                    icon: const Icon(Icons.receipt, size: 16),
                  ),
                ],
                selected: {showVat},
                onSelectionChanged: (Set<bool> selection) {
                  setState(() {
                    showVat = selection.first;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 24.h),
          if (widget.isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: LiquidLoader(
                  size: 60,
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          else if (widget.dailySalesData.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 48.sp,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      l10n.noSalesDataAvailable,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 300.h,
              child: LineChart(
                _buildLineChartData(theme),
                duration: const Duration(milliseconds: 250),
              ),
            ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(ThemeData theme) {
    final data = widget.dailySalesData;
    final maxValue = showVat
        ? data.map((e) => e.totalVat).reduce((a, b) => a > b ? a : b)
        : data.map((e) => e.totalSales).reduce((a, b) => a > b ? a : b);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxValue / 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: theme.colorScheme.surfaceContainerHighest,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < data.length) {
                final date = data[value.toInt()].date;
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    DateFormat('MM/dd').format(date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: maxValue / 5,
            getTitlesWidget: (value, meta) {
              return Text(
                _formatCurrency(value),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          left: BorderSide(
            color: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
      minX: 0,
      maxX: (data.length - 1).toDouble(),
      minY: 0,
      maxY: maxValue * 1.2,
      lineBarsData: [
        LineChartBarData(
          spots: data.asMap().entries.map((entry) {
            return FlSpot(
              entry.key.toDouble(),
              showVat ? entry.value.totalVat : entry.value.totalSales,
            );
          }).toList(),
          isCurved: true,
          color: showVat ? Colors.orange : theme.colorScheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor:
                    showVat ? Colors.orange : theme.colorScheme.primary,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: (showVat ? Colors.orange : theme.colorScheme.primary)
                .withValues(alpha: 0.1),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final date = data[touchedSpot.x.toInt()].date;
              final value = touchedSpot.y;
              return LineTooltipItem(
                '${DateFormat('MMM dd').format(date)}\n${_formatCurrency(value)}',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

/// Widget to display category sales pie chart
class CategorySalesChartWidget extends StatefulWidget {
  final List<CategorySalesData> categorySalesData;
  final bool isLoading;

  const CategorySalesChartWidget({
    super.key,
    required this.categorySalesData,
    this.isLoading = false,
  });

  @override
  State<CategorySalesChartWidget> createState() =>
      _CategorySalesChartWidgetState();
}

class _CategorySalesChartWidgetState extends State<CategorySalesChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return LiquidCard(
      elevation: 3,
      blur: 18,
      opacity: 0.15,
      borderRadius: 12,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: theme.colorScheme.primary,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.salesByCategory,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          if (widget.isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: LiquidLoader(
                  size: 60,
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          else if (widget.categorySalesData.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 48.sp,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      l10n.noCategoryDataAvailable,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 250.h,
                    child: PieChart(
                      _buildPieChartData(theme),
                      duration: const Duration(milliseconds: 250),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        widget.categorySalesData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Row(
                          children: [
                            Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(index),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                category.categoryName,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  PieChartData _buildPieChartData(ThemeData theme) {
    final total = widget.categorySalesData
        .fold<double>(0, (sum, item) => sum + item.totalRevenue);

    return PieChartData(
      pieTouchData: PieTouchData(
        touchCallback: (FlTouchEvent event, pieTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                pieTouchResponse == null ||
                pieTouchResponse.touchedSection == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
          });
        },
      ),
      borderData: FlBorderData(show: false),
      sectionsSpace: 2,
      centerSpaceRadius: 60.r,
      sections: widget.categorySalesData.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final isTouched = index == touchedIndex;
        final fontSize = isTouched ? 16.0 : 12.0;
        final radius = isTouched ? 70.0 : 60.0;
        final percentage = (category.totalRevenue / total * 100);

        return PieChartSectionData(
          color: _getCategoryColor(index),
          value: category.totalRevenue,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: radius.r,
          titleStyle: TextStyle(
            fontSize: fontSize.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList(),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }
}
