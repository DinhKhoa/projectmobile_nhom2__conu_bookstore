import 'package:flutter/material.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/models/customer.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/services/customer_service.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/component/notification_dialog.dart';
import '../../report/presentation/widgets/report_data_table.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  List<Customer> _allCustomers = [];
  List<Customer> _displayedCustomers = [];
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  static const int _pageSize = 10;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    setState(() => _isLoading = true);
    try {
      final customers = await CustomerService.getAllCustomers();
      setState(() {
        _allCustomers = customers;
        _displayedCustomers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi tải dữ liệu khách hàng')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _displayedCustomers = List.from(_allCustomers);
      } else {
        _displayedCustomers = _allCustomers.where((customer) {
          return customer.maKH.toLowerCase().contains(query) ||
              customer.tenKH.toLowerCase().contains(query) ||
              customer.sdt.contains(query);
        }).toList();
      }
      _currentPage = 1;
    });
  }

  void _showCustomerDetailDialog(Customer? customer) {
    bool isEdit = customer != null;
    final nameController = TextEditingController(text: customer?.tenKH ?? '');
    final phoneController = TextEditingController(text: customer?.sdt ?? '');
    final addressController = TextEditingController(text: customer?.diaChi ?? '');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 450,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEdit ? 'THÔNG TIN KHÁCH HÀNG' : 'THÊM KHÁCH HÀNG MỚI',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, color: Colors.white))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField('Tên khách hàng:', nameController),
                      const SizedBox(height: 16),
                      _buildTextField('Số điện thoại:', phoneController),
                      const SizedBox(height: 16),
                      _buildTextField('Địa chỉ:', addressController),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          if (isEdit) ...[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  NotificationDialog.showConfirm(context, 'Xác nhận xóa', 'Bạn có chắc chắn muốn xóa khách hàng này?', () async {
                                    final res = await CustomerService.deleteCustomer(customer.id);
                                    if (res['success'] == true) {
                                      _fetchCustomers();
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        NotificationDialog.showSuccess(context, 'Xóa thành công!');
                                      }
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
                                child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final newCustomer = Customer(
                                  id: customer?.id ?? '',
                                  maKH: customer?.maKH ?? 'KH${_allCustomers.length + 1}',
                                  tenKH: nameController.text,
                                  sdt: phoneController.text,
                                  diaChi: addressController.text,
                                );
                                final Map<String, dynamic> res;
                                if (isEdit) {
                                  res = await CustomerService.updateCustomer(customer.id, newCustomer);
                                } else {
                                  res = await CustomerService.createCustomer(newCustomer);
                                }

                                if (res['success'] == true) {
                                  _fetchCustomers();
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    NotificationDialog.showSuccess(context, isEdit ? 'Cập nhật thành công!' : 'Thêm mới thành công!');
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              child: const Text('Lưu', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchCustomers,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'QUẢN LÝ KHÁCH HÀNG',
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
                          onPressed: () => _showCustomerDetailDialog(null),
                          icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
                          label: const Text('Thêm khách hàng', style: TextStyle(color: Colors.white)),
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
                              onChanged: (_) => _filterCustomers(),
                              decoration: const InputDecoration(
                                hintText: 'Tìm theo tên, điện thoại...',
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

                    ReportDataTable(
                      columns: const ['Mã KH', 'Tên khách hàng', 'Địa chỉ', 'Số điện thoại'],
                      rows: _displayedCustomers
                          .skip((_currentPage - 1) * _pageSize)
                          .take(_pageSize)
                          .map((kh) => [
                            kh.maKH, 
                            kh.tenKH, 
                            kh.diaChi, 
                            kh.sdt
                          ])
                          .toList(),
                      currentPage: _currentPage,
                      totalPages: (_displayedCustomers.length / _pageSize).ceil(),
                      onPageChanged: (page) => setState(() => _currentPage = page),
                      onRowTap: (index) {
                        final customer = _displayedCustomers[(_currentPage - 1) * _pageSize + index];
                        _showCustomerDetailDialog(customer);
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
