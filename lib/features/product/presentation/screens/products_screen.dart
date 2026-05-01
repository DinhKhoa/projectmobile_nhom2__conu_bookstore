import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/utils/formatters.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/presentation/bloc/category_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/domain/entities/product_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/presentation/bloc/product_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/presentation/bloc/product_event.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/presentation/bloc/product_state.dart';

import '../../../report/presentation/widgets/report_data_table.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _appliedSearchQuery = '';
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(LoadProductsRequested());
      context.read<CategoryBloc>().add(LoadCategoriesEvent());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getNextProductCode(List<ProductEntity> products) {
    if (products.isEmpty) return 'HH00001';
    int maxId = 0;
    for (var p in products) {
      final code = p.code;
      if (code.startsWith('HH')) {
        final numStr = code.substring(2);
        final num = int.tryParse(numStr);
        if (num != null && num > maxId) {
          maxId = num;
        }
      }
    }
    final nextId = maxId + 1;
    return 'HH${nextId.toString().padLeft(5, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: BlocConsumer<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductFailure) {
              NotificationDialog.showError(context, state.message);
            }
            if (state is ProductActionSuccess) {
              NotificationDialog.showSuccess(context, state.message);
            }
          },
          builder: (context, state) {
            List<ProductEntity> products = [];
            bool isLoading = false;
            String? errorMessage;
            if (state is ProductLoading) {
              isLoading = true;
            } else if (state is ProductsLoaded) {
              products = state.products;
            } else if (state is ProductFailure) {
              errorMessage = state.message;
            }
            final query = _appliedSearchQuery.toLowerCase();
            final filteredProducts = products.where((p) {
              return p.name.toLowerCase().contains(query) ||
                  p.code.toLowerCase().contains(query) ||
                  p.barcode.toLowerCase().contains(query) ||
                  p.unit.toLowerCase().contains(query) ||
                  (p.categoryName?.toLowerCase().contains(query) ?? false);
            }).toList();
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(LoadProductsRequested());
                context.read<CategoryBloc>().add(LoadCategoriesEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'DANH SÁCH HÀNG HÓA',
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    allProducts: products,
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
                              'Thêm hàng hóa',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
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
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                                horizontal: 24,
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
                    if (isLoading && products.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (errorMessage != null && products.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            TextButton(
                              onPressed: () => context.read<ProductBloc>().add(
                                LoadProductsRequested(),
                              ),
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    else if (products.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('Không có sản phẩm nào'),
                        ),
                      )
                    else
                      ReportDataTable(
                        tableWidth: 1500,
                        columns: const [
                          'Mã hàng',
                          'Tên hàng hóa',
                          'Mã vạch',
                          'Tên loại hàng',
                          'Số lượng',
                          'Ngưỡng báo',
                          'Đơn vị',
                          'Giá bán',
                          '% Lợi nhuận',
                          'Trạng thái',
                        ],
                        rows: filteredProducts
                            .skip((_currentPage - 1) * _pageSize)
                            .take(_pageSize)
                            .map(
                              (p) => [
                                p.code,
                                p.name,
                                p.barcode,
                                p.categoryName ?? '',
                                p.quantity.toString(),
                                p.minStock.toString(),
                                p.unit,
                                AppFormatters.formatCurrency(p.price),
                                '${p.profit}%',
                                p.status == 'active' ? 'Đang bán' : 'Ngừng bán',
                              ],
                            )
                            .toList(),
                        currentPage: _currentPage,
                        totalPages: (filteredProducts.length / _pageSize)
                            .ceil()
                            .clamp(1, double.infinity)
                            .toInt(),
                        onPageChanged: (page) =>
                            setState(() => _currentPage = page),
                        onRowTap: (index) {
                          final product =
                              filteredProducts[(_currentPage - 1) * _pageSize +
                                  index];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: product),
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
