import 'package:flutter/material.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/models/category.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/models/product.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/services/category_service.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/services/product_service.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/component/notification_dialog.dart';
import '../../report/presentation/widgets/report_data_table.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;
  const CategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late Category _category;
  bool _isLoading = false;
  List<Product> _products = [];
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _category = widget.category;
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      // Lấy toàn bộ hàng hoá và lọc client-side theo `MaLoai` của category hiện tại
      final allProducts = await ProductService.getAllProducts();
      setState(() {
        _products = allProducts.where((p) => p.maLoaiId == _category.id).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loi tai hang hoa theo loai')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final totalPages = (_products.length / _pageSize).ceil();
    final screenWidth = MediaQuery.of(context).size.width;
    final detailTableWidth = screenWidth * 0.9;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CommonAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'DANH SÁCH LOẠI HÀNG',
                style: AppTextStyles.subHeading.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 64,
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      _category.tenLoai,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchProducts,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                              Text(
                                'Danh sách hàng hóa',
                                style: AppTextStyles.subHeading.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                          const SizedBox(height: 12),
                          Center(
                            child: ReportDataTable(
                              columns: const ['Mã HH', 'Tên hàng hóa', 'Giá bán'],
                              rows: _products
                                  .skip((_currentPage - 1) * _pageSize)
                                  .take(_pageSize)
                                  .map((p) => [
                                        p.maHH,
                                        p.tenHH,
                                        p.giaBan.toStringAsFixed(0),
                                      ])
                                  .toList(),
                              currentPage: _currentPage,
                              totalPages: totalPages == 0 ? 1 : totalPages,
                              tableWidth: detailTableWidth,
                              onPageChanged: (page) => setState(() => _currentPage = page),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

}
