import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/domain/entities/customer_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/presentation/bloc/customer_bloc.dart';

import '../../../report/presentation/widgets/report_data_table.dart';
import 'customer_detail_screen.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _appliedSearchQuery = '';
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerBloc>().add(LoadCustomersEvent());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getNextCustomerCode(List<CustomerEntity> customers) {
    if (customers.isEmpty) return 'KH0001';
    int maxId = 0;
    for (var customer in customers) {
      final code = customer.code;
      if (code.startsWith('KH')) {
        final numStr = code.substring(2);
        final num = int.tryParse(numStr);
        if (num != null && num > maxId) {
          maxId = num;
        }
      }
    }
    final nextId = maxId + 1;
    return 'KH${nextId.toString().padLeft(4, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: BlocConsumer<CustomerBloc, CustomerState>(
          listener: (context, state) {
            if (state is CustomerError) {
              NotificationDialog.showError(context, state.message);
            }
            if (state is CustomerActionSuccess) {
              NotificationDialog.showSuccess(context, state.message);
            }
          },
          builder: (context, state) {
            List<CustomerEntity> customers = [];
            bool isLoading = false;
            if (state is CustomerLoading) {
              isLoading = true;
            } else if (state is CustomerLoaded) {
              customers = state.customers;
            }
            final query = _appliedSearchQuery.toLowerCase();
            final filteredCustomers = customers.where((kh) {
              return kh.code.toLowerCase().contains(query) ||
                  kh.name.toLowerCase().contains(query) ||
                  kh.phone.contains(query) ||
                  (kh.address?.toLowerCase().contains(query) ?? false);
            }).toList();
            return RefreshIndicator(
              onRefresh: () async {
                context.read<CustomerBloc>().add(LoadCustomersEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'DANH SÁCH KHÁCH HÀNG',
                      style: AppTextStyles.subHeading.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final nextCode = _getNextCustomerCode(customers);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerDetailScreen(
                                suggestedCode: nextCode,
                                allCustomers: customers,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Thêm khách hàng',
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
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                              ),
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
                                contentPadding: const EdgeInsets.only(
                                  bottom: 9,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _appliedSearchQuery = _searchController.text;
                                _currentPage = 1;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
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
                    if (isLoading && customers.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else
                      ReportDataTable(
                        columns: const [
                          'Mã KH',
                          'Tên khách hàng',
                          'Địa chỉ',
                          'Số điện thoại',
                        ],
                        rows: filteredCustomers
                            .skip((_currentPage - 1) * _pageSize)
                            .take(_pageSize)
                            .map(
                              (kh) => [
                                kh.code,
                                kh.name,
                                kh.address ?? '',
                                kh.phone,
                              ],
                            )
                            .toList(),
                        currentPage: _currentPage,
                        totalPages: (filteredCustomers.length / _pageSize)
                            .ceil()
                            .clamp(1, double.infinity)
                            .toInt(),
                        onPageChanged: (page) =>
                            setState(() => _currentPage = page),
                        onRowTap: (index) {
                          final customer =
                              filteredCustomers[(_currentPage - 1) * _pageSize +
                                  index];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerDetailScreen(
                                customer: customer,
                                allCustomers: customers,
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
