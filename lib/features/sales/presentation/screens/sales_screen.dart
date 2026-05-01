import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/utils/formatters.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/data/datasources/customer_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/data/models/customer_model.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/features.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/data/datasources/product_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/data/models/product_model.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/presentation/widgets/report_data_table.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/data/datasources/order_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/data/models/order_model.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/domain/entities/order_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/injection_container.dart';

import 'add_sale_screen.dart';
import 'sale_detail_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<OrderModel> _allOrders = [];
  List<OrderModel> _displayedOrders = [];
  List<ProductModel> _products = [];
  List<CustomerModel> _customers = [];
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  static const int _pageSize = 10;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        sl<OrderRemoteDataSource>().getAllOrders(),
        sl<ProductRemoteDataSource>().getAllProducts(),
        sl<CustomerRemoteDataSource>().getAllCustomers(),
      ]);
      final orders = results[0] as List<OrderModel>;
      _products = results[1] as List<ProductModel>;
      _customers = results[2] as List<CustomerModel>;
      final List<OrderModel> enrichedOrders = orders.map((order) {
        String? enrichedCustomerCode = order.customerCode;
        String? enrichedCustomerAddress = order.customerAddress;
        if (enrichedCustomerCode == null ||
            enrichedCustomerCode.isEmpty ||
            enrichedCustomerAddress == null ||
            enrichedCustomerAddress.isEmpty) {
          try {
            final fullCustomer = _customers.firstWhere(
              (c) => c.id == order.customerId,
            );
            enrichedCustomerCode ??= fullCustomer.code;
            enrichedCustomerAddress ??= fullCustomer.address;
          } catch (_) {}
        }
        final List<OrderItemEntity> betterItems = [];
        for (var item in order.items) {
          if (item.product.name.isEmpty) {
            try {
              final searchId = item.product.id.toString().trim();
              if (searchId.isNotEmpty) {
                final fullProduct = _products.firstWhere(
                  (p) =>
                      p.id.toString().trim() == searchId ||
                      p.code.toString().trim() == searchId ||
                      p.barcode.toString().trim() == searchId,
                );
                betterItems.add(
                  OrderItemEntity(
                    product: fullProduct,
                    quantity: item.quantity,
                    discount: item.discount,
                  ),
                );
                continue;
              }
            } catch (_) {}
          }
          betterItems.add(item);
        }
        return OrderModel(
          id: order.id,
          customerId: order.customerId,
          customerCode: enrichedCustomerCode,
          customerName: order.customerName,
          customerPhone: order.customerPhone,
          customerAddress: enrichedCustomerAddress,
          items: betterItems,
          totalAmount: order.totalAmount,
          discount: order.discount,
          paymentMethod: order.paymentMethod,
          createdAt: order.createdAt,
        );
      }).toList();
      if (!mounted) return;
      setState(() {
        _allOrders = enrichedOrders;
        _displayedOrders = enrichedOrders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải danh sách đơn hàng: $e'),
            backgroundColor: Colors.red,
          ),
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
          return (order.id ?? '').toLowerCase().contains(query) ||
              order.customerName.toLowerCase().contains(query);
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
                  'DANH SÁCH HÓA ĐƠN',
                  style: AppTextStyles.subHeading.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToAddSale,
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Thêm hóa đơn',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontSize: 14.5),
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm',
                            hintStyle: const TextStyle(
                              fontSize: 14.5,
                              color: AppColors.textHint,
                            ),
                            border: InputBorder.none,
                            prefixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 14),
                                const Icon(
                                  Icons.search,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  height: 16,
                                  width: 1,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                            contentPadding: const EdgeInsets.only(bottom: 9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _filterOrders,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Tìm kiếm',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth;
                      final tableWidth = availableWidth < 720
                          ? availableWidth
                          : 720.0;
                      return Center(
                        child: ReportDataTable(
                          tableWidth: tableWidth,
                          columns: const [
                            'Mã Hóa Đơn',
                            'Ngày bán',
                            'SDT khách hàng',
                            'Tổng thành tiền',
                          ],
                          rows: _displayedOrders
                              .skip((_currentPage - 1) * _pageSize)
                              .take(_pageSize)
                              .map(
                                (o) => [
                                  o.id ?? '---',
                                  o.createdAt != null
                                      ? DateFormat(
                                          'dd/MM/yyyy HH:mm',
                                        ).format(o.createdAt!)
                                      : '---',
                                  o.customerPhone ?? 'Khách lẻ',
                                  AppFormatters.formatCurrency(o.totalAmount),
                                ],
                              )
                              .toList(),
                          currentPage: _currentPage,
                          totalPages: (_displayedOrders.length / _pageSize)
                              .ceil(),
                          onPageChanged: (page) =>
                              setState(() => _currentPage = page),
                          onRowTap: (index) {
                            final actualIndex =
                                (_currentPage - 1) * _pageSize + index;
                            if (actualIndex >= 0 &&
                                actualIndex < _displayedOrders.length) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SaleDetailScreen(
                                    order: _displayedOrders[actualIndex],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
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
}
