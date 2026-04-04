import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/core.dart';
import '../../data/report_models.dart';

class RevenueBarChart extends StatelessWidget {
  final List<DailyRevenue> data;
  final String title;
  final VoidCallback onViewDetails;

  const RevenueBarChart({
    super.key,
    required this.data,
    required this.title,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxAmount = data.isNotEmpty 
        ? data.map((e) => e.netRevenue).reduce((a, b) => a > b ? a : b)
        : 1000.0;
    final interval = (maxAmount / 4).ceilToDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.subHeading.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton(
                onPressed: onViewDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(100, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Xem chi tiết', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 40),
          AspectRatio(
            aspectRatio: 1.2,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxAmount * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${data[groupIndex].formattedDate}\n${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(rod.toY)}',
                        const TextStyle(color: Colors.white, fontSize: 10),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) return const SizedBox.shrink();
                        // Only show every 2-3 titles to avoid crowding if too many days
                        if (data.length > 7 && index % (data.length / 4).ceil() != 0) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          space: 8,
                          child: Text(
                            data[index].formattedDate,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: interval > 0 ? interval : 1,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('0đ', style: TextStyle(fontSize: 10));
                        if (value >= 1000000) {
                          return Text('${(value / 1000000).toStringAsFixed(1)}tr', 
                            style: const TextStyle(fontSize: 10));
                        }
                        return Text('${(value / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval > 0 ? interval : 1,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: AppColors.divider,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data[index].netRevenue,
                        color: const Color(0xFF63A9FF),
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(2),
                          topRight: Radius.circular(2),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
