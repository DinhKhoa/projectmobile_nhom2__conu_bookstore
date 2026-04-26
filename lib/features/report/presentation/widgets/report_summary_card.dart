import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class ReportSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final double percentage;

  const ReportSummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.percentage = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPositive = percentage >= 0;
    final Color color = isPositive ? Colors.green : Colors.red;
    final IconData icon = isPositive ? Icons.north_east : Icons.south_east;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
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
          Text(
            title,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 24,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${percentage.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
