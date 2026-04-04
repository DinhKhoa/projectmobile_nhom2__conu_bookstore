import 'package:flutter/material.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/models/product.dart' as model;
import 'package:projectmobile_nhom2__conu_bookstore/core/models/category.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/services/product_service.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/services/category_service.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/component/notification_dialog.dart';
import '../../report/presentation/widgets/report_data_table.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<model.Product> _allProducts = [];
  List<model.Product> _displayedProducts = [];
  List<Category> _categories = [];
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  static const int _pageSize = 10;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ProductService.getAllProducts(),
        CategoryService.getAllCategories(),
      ]);
      setState(() {
        _allProducts = results[0] as List<model.Product>;
        _displayedProducts = _allProducts;
        _categories = results[1] as List<Category>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi tải dữ liệu hàng hóa')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _displayedProducts = List.from(_allProducts);
      } else {
        _displayedProducts = _allProducts.where((product) {
          return product.maVach.toLowerCase().contains(query) ||
              product.tenHH.toLowerCase().contains(query);
        }).toList();
      }
      _currentPage = 1;
    });
  }

  void _showProductFormDialog(model.Product? product) {
    bool isEdit = product != null;
    final nameController = TextEditingController(text: product?.tenHH ?? '');
    final priceController = TextEditingController(text: product?.giaBan.toString() ?? '');
    final profitController = TextEditingController(text: product?.loiNhuan.toString() ?? '');
    final stockController = TextEditingController(text: product?.soLuong.toString() ?? '');
    final unitController = TextEditingController(text: product?.donViTinh ?? 'cuốn');
    String? selectedCategoryId = product?.maLoaiId;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 500,
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
                          isEdit ? 'THÔNG TIN HÀNG HÓA' : 'NHẬP HÀNG HÓA MỚI',
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
                      _buildTextField('Tên hàng hóa:', nameController),
                      const SizedBox(height: 12),
                      const Text('Loại hàng:', style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButtonFormField<String>(
                        value: selectedCategoryId,
                        items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.tenLoai))).toList(),
                        onChanged: (val) => selectedCategoryId = val,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Giá bán:', priceController, isNumber: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField('Lợi nhuận:', profitController, isNumber: true)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Tồn kho:', stockController, isNumber: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField('Đơn vị:', unitController)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          if (isEdit) ...[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  NotificationDialog.showConfirm(context, 'Xác nhận xóa', 'Bạn có chắc chắn muốn xóa hàng hóa này?', () async {
                                    final res = await ProductService.deleteProduct(product.id);
                                    if (res['success'] == true) {
                                      _fetchData();
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
                                final newP = model.Product(
                                  id: product?.id ?? '',
                                  tenHH: nameController.text,
                                  maHH: product?.maHH ?? '',
                                  maVach: product?.maVach ?? '',
                                  maLoai: selectedCategoryId ?? '',
                                  giaBan: double.tryParse(priceController.text) ?? 0,
                                  loiNhuan: double.tryParse(profitController.text) ?? 0,
                                  soLuong: int.tryParse(stockController.text) ?? 0,
                                  donViTinh: unitController.text,
                                  nguongCanhBao: product?.nguongCanhBao ?? 10,
                                  trangThai: product?.trangThai ?? 'active',
                                );
                                final Map<String, dynamic> res;
                                if (isEdit) {
                                  res = await ProductService.updateProduct(product.id, newP);
                                } else {
                                  res = await ProductService.createProduct(newP);
                                }

                                if (res['success'] == true) {
                                  _fetchData();
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

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              onRefresh: _fetchData,
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
                        ElevatedButton.icon(
                          onPressed: () => _showProductFormDialog(null),
                          icon: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
                          label: const Text('Thêm hàng hóa', style: TextStyle(color: Colors.white)),
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
                              onChanged: (_) => _filterProducts(),
                              decoration: const InputDecoration(
                                hintText: 'Tìm theo tên, SKU...',
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
                      columns: const ['SKU', 'Tên hàng hoá', 'Loại hàng', 'Số lượng', 'ĐVT', 'Giá bán'],
                      rows: _displayedProducts
                          .skip((_currentPage - 1) * _pageSize)
                          .take(_pageSize)
                          .map((p) => [
                            p.maVach, 
                            p.tenHH, 
                            p.categoryName, 
                            p.soLuong.toString(), 
                            p.donViTinh, 
                            p.giaBan.toStringAsFixed(0)
                          ])
                          .toList(),
                      currentPage: _currentPage,
                      totalPages: (_displayedProducts.length / _pageSize).ceil(),
                      onPageChanged: (page) => setState(() => _currentPage = page),
                      onRowTap: (index) {
                        final product = _displayedProducts[(_currentPage - 1) * _pageSize + index];
                        _showProductFormDialog(product);
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
