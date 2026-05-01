import 'package:flutter/material.dart';

import '../../../../core/core.dart';

class ReportDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<dynamic>> rows;
  final bool alternateRowColor;
  final int currentPage;
  final int totalPages;
  final Function(int)? onPageChanged;
  final String? trendType;
  final Function(int)? onRowTap;
  final double? tableWidth;

  const ReportDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.alternateRowColor = true,
    this.currentPage = 1,
    this.totalPages = 1,
    this.onPageChanged,
    this.trendType,
    this.onRowTap,
    this.tableWidth,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalController = ScrollController();
    if (rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 60),
        alignment: Alignment.center,
        child: const Text(
          'Chưa có dữ liệu',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return Column(
      children: [
        Scrollbar(
          controller: horizontalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: horizontalController,
            scrollDirection: Axis.horizontal,
            child: Container(
              width: tableWidth ?? (columns.length <= 2 ? 600 : 1150),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 0,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(3),
                        topRight: Radius.circular(3),
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: columns.asMap().entries.map((entry) {
                          final i = entry.key;
                          final col = entry.value;
                          return Expanded(
                            flex: i == 0 ? 3 : 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  right: i == columns.length - 1
                                      ? BorderSide.none
                                      : const BorderSide(
                                          color: AppColors.divider,
                                        ),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                col,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  ...List.generate(rows.length, (index) {
                    final isEven = index % 2 == 0;
                    return GestureDetector(
                      onTap: () => onRowTap?.call(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: alternateRowColor && !isEven
                              ? const Color(0xFFF3F8FB)
                              : AppColors.backgroundWhite,
                          border: Border(
                            bottom: index == rows.length - 1
                                ? BorderSide.none
                                : const BorderSide(color: AppColors.divider),
                          ),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: rows[index].asMap().entries.map((entry) {
                              final colIndex = entry.key;
                              final text = entry.value;
                              final isLastColumn =
                                  colIndex == columns.length - 1;
                              return Expanded(
                                flex: colIndex == 0 ? 3 : 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: isLastColumn
                                          ? BorderSide.none
                                          : const BorderSide(
                                              color: AppColors.divider,
                                            ),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: entry.value is Widget
                                            ? (entry.value as Widget)
                                            : Text(
                                                entry.value.toString(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textPrimary,
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                      ),
                                      if (isLastColumn &&
                                          trendType != null) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          trendType == 'up'
                                              ? Icons.north_east
                                              : Icons.south_east,
                                          color: trendType == 'up'
                                              ? Colors.green
                                              : Colors.red,
                                          size: 14,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        if (totalPages > 1)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              border: Border.all(color: AppColors.divider),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trang $currentPage / $totalPages',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: currentPage > 1
                          ? () => onPageChanged?.call(currentPage - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: currentPage < totalPages
                          ? () => onPageChanged?.call(currentPage + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
