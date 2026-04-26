import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectmobile_nhom2_conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2_conu_bookstore/core/services/report_service.dart';
import '../data/report_models.dart';
import 'widgets/report_data_table.dart';
import 'widgets/report_summary_card.dart';
import 'widgets/revenue_bar_chart.dart';

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
  bool _isSearched = false;
  bool _isLoading = false;
  int _currentPage = 1;
  static const int _pageSize = 10;

  // Data
  RevenueSummary? _revenueSummary;
  List<DailyRevenue> _dailyRevenue = [];
  List<ProductReportItem> _productItems = [];

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    // Start with empty dates as per user request
    _startDateController.text = '';
    _endDateController.text = '';
  }

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
      initialDate: controller.text.isNotEmpty ? _dateFormat.parse(controller.text) : now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
        controller.text = _dateFormat.format(picked);
      });
    }
  }

  Future<void> _handleSearch() async {
    if (_selectedReportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn loại báo cáo')),
      );
      return;
    }

    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đầy đủ ngày bắt đầu và ngày kết thúc')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearched = true;
      _showTable = false;
      _currentPage = 1;
    });

    try {
      if (_selectedReportType == 'Doanh thu theo thời gian') {
        final result = await ReportService.getRevenueReport(
          startDate: _startDateController.text,
          endDate: _endDateController.text,
        );
        setState(() {
          _dailyRevenue = result.daily;
          _revenueSummary = result.summary;
        });
      } else if (_selectedReportType == 'Hàng hóa bán chạy') {
        final items = await ReportService.getProductReport(
          startDate: _startDateController.text,
          endDate: _endDateController.text,
          slowSelling: false,
        );
        setState(() => _productItems = items);
      } else if (_selectedReportType == 'Hàng hóa bán chậm') {
        final items = await ReportService.getProductReport(
          startDate: _startDateController.text,
          endDate: _endDateController.text,
          slowSelling: true,
        );
        setState(() => _productItems = items);
      }
    } catch (e) {
      debugPrint('Error fetching report: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải báo cáo: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                _selectedReportType?.toUpperCase() ?? 'BÁO CÁO',
                style: AppTextStyles.subHeading.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildFilters(),
            const SizedBox(height: 24),
            if (_isSearched) _buildReportContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        _buildDateField(
          label: AppConstants.reportStartDate,
          controller: _startDateController,
        ),
        const SizedBox(height: 12),
        _buildDateField(
          label: AppConstants.reportEndDate,
          controller: _endDateController,
        ),
        const SizedBox(height: 12),
        _buildReportTypeDropdown(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Tìm kiếm', style: AppTextStyles.button),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSearched = false;
                    _selectedReportType = null;
                  });
                },
                child: const Text('Hủy', style: TextStyle(color: AppColors.textPrimary)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_selectedReportType == 'Doanh thu theo thời gian') {
      return _showTable ? _buildDetailedRevenueTable() : _buildRevenueOverview();
    } else {
      return _buildProductRankingTable();
    }
  }

  Widget _buildRevenueOverview() {
    if (_revenueSummary == null) return const SizedBox.shrink();
    return Column(
      children: [
        ReportSummaryCard(
          title: 'Doanh thu thuần',
          value: _currencyFormat.format(_revenueSummary!.netRevenue),
          percentage: _revenueSummary!.netRevenueChange,
        ),
        ReportSummaryCard(
          title: 'Lợi nhuận gộp',
          value: _currencyFormat.format(_revenueSummary!.grossProfit),
          percentage: _revenueSummary!.grossProfitChange,
        ),
        ReportSummaryCard(
          title: 'Đơn hàng',
          value: _revenueSummary!.totalOrders.toString(),
          percentage: _revenueSummary!.totalOrdersChange,
        ),
        const SizedBox(height: 16),
        RevenueBarChart(
          data: _dailyRevenue,
          title: 'Tổng doanh thu',
          onViewDetails: () => setState(() => _showTable = true),
        ),
      ],
    );
  }

  Widget _buildDetailedRevenueTable() {
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
            'Ngày', 'SL đơn hàng', 'Tiền hàng', 'Chiết khấu',
            'Tiền hàng trả lại', 'Doanh thu thuần', 'Tiền thuế', 'Tổng doanh thu'
          ],
          rows: _dailyRevenue
              .skip((_currentPage - 1) * _pageSize)
              .take(_pageSize)
              .map((d) => [
                    d.fullFormattedDate,
                    d.orderCount.toString(),
                    _currencyFormat.format(d.totalAmount),
                    _currencyFormat.format(d.discount),
                    _currencyFormat.format(d.returnAmount),
                    _currencyFormat.format(d.netRevenue),
                    _currencyFormat.format(d.tax),
                    _currencyFormat.format(d.totalRevenue),
                  ])
              .toList(),
          currentPage: _currentPage,
          totalPages: (_dailyRevenue.length / _pageSize).ceil(),
          onPageChanged: (page) => setState(() => _currentPage = page),
        ),
      ],
    );
  }

  Widget _buildProductRankingTable() {
    return Column(
      children: [
        ReportDataTable(
          columns: const [
            'Tên hàng hóa', 'Loại hàng', 'SL bán', 'Tiền hàng',
            'Chiết khấu', 'Tiền hàng trả lại', 'Doanh thu thuần', 'Tổng doanh thu'
          ],
          rows: _productItems
              .skip((_currentPage - 1) * _pageSize)
              .take(_pageSize)
              .map((p) => [
                    p.productName,
                    p.category,
                    p.soldQuantity.toString(),
                    _currencyFormat.format(p.totalRevenue),
                    _currencyFormat.format(p.discount),
                    _currencyFormat.format(p.returnAmount),
                    _currencyFormat.format(p.netRevenue),
                    _currencyFormat.format(p.totalRevenueWithTax),
                  ])
              .toList(),
          currentPage: _currentPage,
          totalPages: (_productItems.length / _pageSize).ceil(),
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
            width: 100,
            child: Text(label, style: AppTextStyles.label),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(controller),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    fillColor: const Color(0xFFE0E0E0),
                    filled: true,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    prefixIcon: const Icon(Icons.calendar_today, size: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                ),
              ),
            ),
          ),
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
            width: 100,
            child: Text(AppConstants.reportType, style: AppTextStyles.label),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.zero,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedReportType,
                  hint: const Text(
                    AppConstants.reportTypePlaceholder,
                    style: TextStyle(fontSize: 13, color: AppColors.textHint),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  items: AppConstants.reportTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedReportType = value;
                      _isSearched = false;
                      _currentPage = 1;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
