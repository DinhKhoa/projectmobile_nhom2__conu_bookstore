import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/utils/formatters.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/domain/entities/report_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/presentation/bloc/report_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/injection_container.dart';

import '../widgets/report_data_table.dart';
import '../widgets/report_summary_card.dart';
import '../widgets/revenue_bar_chart.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  String? _selectedReportType;
  bool _showTable = false;
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(controller.text)
          : now,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = AppFormatters.formatDate(picked);
      });
    }
  }

  void _handleSearch(BuildContext context) {
    if (_selectedReportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn loại báo cáo')),
      );
      return;
    }
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn đầy đủ ngày bắt đầu và ngày kết thúc'),
        ),
      );
      return;
    }
    final start = DateFormat('dd/MM/yyyy').parse(_startDateController.text);
    final end = DateFormat('dd/MM/yyyy').parse(_endDateController.text);
    if (start.isAfter(end)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ngày bắt đầu không thể lớn hơn ngày kết thúc'),
        ),
      );
      return;
    }
    setState(() {
      _showTable = false;
      _currentPage = 1;
    });
    if (_selectedReportType == 'Doanh thu theo thời gian') {
      context.read<ReportBloc>().add(
        GetRevenueReportRequested(
          _startDateController.text,
          _endDateController.text,
        ),
      );
    } else {
      context.read<ReportBloc>().add(
        GetProductReportRequested(
          _startDateController.text,
          _endDateController.text,
          _selectedReportType == 'Hàng hóa bán chậm',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ReportBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Builder(
              builder: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    _selectedReportType?.toUpperCase() ?? 'TỔNG QUAN BÁO CÁO',
                    style: AppTextStyles.subHeading.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFilters(context),
                  const SizedBox(height: 24),
                  _buildBlocContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlocContent() {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        if (state is ReportLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state is ReportFailure) {
          return Center(
            child: Text(
              'Lỗi: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        if (state is RevenueReportLoaded) {
          return _showTable
              ? _buildDetailedRevenueTable(state.daily)
              : _buildRevenueOverview(state.summary, state.daily);
        }
        if (state is ProductReportLoaded) {
          return _buildProductRankingTable(state.products);
        }
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Center(
            child: Image.asset(
              'assets/images/co_nu_xanh.png',
              width: 300,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.book, size: 100, color: AppColors.primary),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateField(
          label: 'Ngày Bắt Đầu:',
          controller: _startDateController,
        ),
        const SizedBox(height: 12),
        _buildDateField(
          label: 'Ngày Kết Thúc:',
          controller: _endDateController,
        ),
        const SizedBox(height: 12),
        _buildReportTypeDropdown(),
        const SizedBox(height: 20),
        SizedBox(
          height: 36,
          child: ElevatedButton(
            onPressed: () => _handleSearch(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              elevation: 2,
            ),
            child: const Text(
              'Tìm kiếm',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueOverview(
    RevenueSummaryEntity summary,
    List<DailyRevenueEntity> daily,
  ) {
    return Column(
      children: [
        ReportSummaryCard(
          title: 'Doanh thu thuần',
          value: AppFormatters.formatCurrency(summary.netRevenue),
          percentage: summary.netRevenueChange,
        ),
        ReportSummaryCard(
          title: 'Lợi nhuận gộp',
          value: AppFormatters.formatCurrency(summary.grossProfit),
          percentage: summary.grossProfitChange,
        ),
        ReportSummaryCard(
          title: 'Đơn hàng',
          value: summary.totalOrders.toString(),
          percentage: summary.totalOrdersChange,
        ),
        const SizedBox(height: 16),
        RevenueBarChart(
          data: daily,
          title: 'Tổng doanh thu',
          onViewDetails: () => setState(() => _showTable = true),
        ),
      ],
    );
  }

  Widget _buildDetailedRevenueTable(List<DailyRevenueEntity> daily) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => setState(() => _showTable = false),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Quay lại biểu đồ'),
        ),
        const SizedBox(height: 8),
        ReportDataTable(
          columns: const [
            'Ngày',
            'SL đơn hàng',
            'Tiền hàng',
            'Doanh thu thuần',
          ],
          rows: daily
              .skip((_currentPage - 1) * _pageSize)
              .take(_pageSize)
              .map(
                (d) => [
                  d.fullFormattedDate,
                  d.orderCount.toString(),
                  AppFormatters.formatCurrency(d.totalAmount),
                  AppFormatters.formatCurrency(d.netRevenue),
                ],
              )
              .toList(),
          currentPage: _currentPage,
          totalPages: (daily.length / _pageSize).ceil() == 0
              ? 1
              : (daily.length / _pageSize).ceil(),
          onPageChanged: (page) => setState(() => _currentPage = page),
        ),
      ],
    );
  }

  Widget _buildProductRankingTable(List<ProductReportEntity> products) {
    return Column(
      children: [
        ReportDataTable(
          columns: const [
            'Tên hàng hóa',
            'Loại hàng',
            'SL bán',
            'Tiền hàng',
            'Doanh thu thuần',
          ],
          rows: products
              .skip((_currentPage - 1) * _pageSize)
              .take(_pageSize)
              .map(
                (p) => [
                  p.productName,
                  p.category,
                  p.soldQuantity.toString(),
                  AppFormatters.formatCurrency(p.totalRevenue),
                  AppFormatters.formatCurrency(p.netRevenue),
                ],
              )
              .toList(),
          currentPage: _currentPage,
          totalPages: (products.length / _pageSize).ceil() == 0
              ? 1
              : (products.length / _pageSize).ceil(),
          onPageChanged: (page) => setState(() => _currentPage = page),
          trendType: _selectedReportType == 'Hàng hóa bán chạy' ? 'up' : 'down',
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(controller),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black87),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black87),
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildReportTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(
            width: 110,
            child: Text(
              'Loại báo cáo:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: 36,
                  child: DropdownMenu<String>(
                    width: constraints.maxWidth,
                    initialSelection: _selectedReportType,
                    hintText: 'Chọn loại báo cáo',
                    textStyle: const TextStyle(fontSize: 14),
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      constraints: const BoxConstraints(
                        maxHeight: 36,
                        minHeight: 36,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black87),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black87),
                      ),
                    ),
                    onSelected: (value) {
                      setState(() {
                        _selectedReportType = value;
                        _currentPage = 1;
                      });
                    },
                    dropdownMenuEntries: AppConstants.reportTypes.map((type) {
                      return DropdownMenuEntry<String>(
                        value: type,
                        label: type,
                        style: MenuItemButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
