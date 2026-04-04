import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/models/order.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/services/order_service.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/models/customer.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/presentation/widgets/report_data_table.dart';
import 'add_sale_screen.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  List<Order> _allOrders = [];
  List<Order> _displayedOrders = [];
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  static const int _pageSize = 10;
  bool _isLoading = false;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await OrderService.getOrders();
      setState(() {
        _allOrders = orders;
        _displayedOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách đơn hàng: $e')),
        );
      }
    }
  }

  void _filterOrders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _displayedOrders = List.from(_allOrders);
      } else {
        _displayedOrders = _allOrders.where((order) {
          final customerName = (order.maKH is Customer) ? (order.maKH as Customer).tenKH : 'Khách lẻ';
          return order.maHoaDonBan.toLowerCase().contains(query) ||
              customerName.toLowerCase().contains(query);
        }).toList();
      }
      _currentPage = 1;
    });
  }

  void _navigateToAddSale() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSaleScreen()),
    );
    if (result == true) {
      _fetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchOrders,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'DANH SÁCH ĐƠN BÁN HÀNG',
                  style: AppTextStyles.subHeading.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _navigateToAddSale,
                      icon: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
                      label: const Text('Thêm hóa đơn', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => _filterOrders(),
                          decoration: const InputDecoration(
                            hintText: 'Tìm theo mã, khách hàng...',
                            hintStyle: TextStyle(fontSize: 14, color: AppColors.textHint),
                            prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                if (_isLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                else
                  ReportDataTable(
                    columns: const ['Mã phiếu', 'Ngày bán', 'Khách hàng', 'Tổng thu', 'Trạng thái'],
                    rows: _displayedOrders
                        .skip((_currentPage - 1) * _pageSize)
                        .take(_pageSize)
                        .map((o) => [
                          o.maHoaDonBan,
                          DateFormat('dd/MM/yyyy HH:mm').format(o.ngayBan),
                          (o.maKH is Customer) ? (o.maKH as Customer).tenKH : 'Khách lẻ',
                          _currencyFormat.format(o.tongThanhTien),
                          _buildStatusTag(o.trangThai),
                        ])
                        .toList(),
                    currentPage: _currentPage,
                    totalPages: (_displayedOrders.length / _pageSize).ceil(),
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    onRowTap: (index) {
                      // Detail functionality can be added later
                    },
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color;
    String text;
    switch (status) {
      case 'Hoàn thành':
        color = Colors.green;
        text = 'Hoàn thành';
        break;
      case 'Bị hủy':
        color = Colors.red;
        text = 'Đã hủy';
        break;
      default:
        color = Colors.orange;
        text = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
