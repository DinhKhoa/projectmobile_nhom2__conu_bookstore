import 'package:flutter/material.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/models/category.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/services/category_service.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/component/notification_dialog.dart';
import '../../report/presentation/widgets/report_data_table.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> _allCategories = [];
  List<Category> _displayedCategories = [];
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  static const int _pageSize = 10;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await CategoryService.getAllCategories();
      setState(() {
        _allCategories = categories;
        _displayedCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi tải dữ liệu loại hàng')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _displayedCategories = List.from(_allCategories);
      } else {
        _displayedCategories = _allCategories.where((category) {
          return category.maLoai.toLowerCase().contains(query) ||
              category.tenLoai.toLowerCase().contains(query);
        }).toList();
      }
      _currentPage = 1;
    });
  }

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'THÊM MỚI LOẠI HÀNG',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.white, size: 24),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Thông Tin Loại Hàng:',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text('Tên LH:', style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'VD: Đồ chơi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              ),
                              child: const Text('Hủy'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                  if (nameController.text.trim().isNotEmpty) {
                                    final newCat = Category(id: '', maLoai: 'L${_allCategories.length + 1}', tenLoai: nameController.text.trim(), trangThai: 'active');
                                    final result = await CategoryService.createCategory(newCat);
                                  if (result['success'] == true) {
                                    _fetchCategories();
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      NotificationDialog.showSuccess(context, 'Thêm Mới Loại Hàng Thành Công!');
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              ),
                              child: const Text('Lưu', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditCategoryDialog(Category category) {
    final TextEditingController nameController = TextEditingController(text: category.tenLoai);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'CẬP NHẬT LOẠI HÀNG',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.white, size: 24),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Mã LH: ${category.maLoai}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Text('Tên LH:', style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                NotificationDialog.showConfirm(context, 'Xác nhận xóa', 'Bạn có chắc chắn muốn xóa loại hàng này?', () async {
                                  final res = await CategoryService.deleteCategory(category.id);
                                  if (res['success'] == true) {
                                    _fetchCategories();
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
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (nameController.text.trim().isNotEmpty) {
                                  final updated = Category(id: category.id, maLoai: category.maLoai, tenLoai: nameController.text.trim(), trangThai: category.trangThai);
                                  final result = await CategoryService.updateCategory(category.id, updated);
                                  if (result['success'] == true) {
                                    _fetchCategories();
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      NotificationDialog.showSuccess(context, 'Cập nhật thành công!');
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              child: const Text('Lưu', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
              onRefresh: _fetchCategories,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'DANH SÁCH LOẠI HÀNG',
                      style: AppTextStyles.subHeading.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _showAddCategoryDialog,
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                          label: const Text('Thêm loại hàng', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE0E0E0)),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (_) => _filterCategories(),
                                  decoration: const InputDecoration(
                                    hintText: 'Tìm kiếm',
                                    hintStyle: TextStyle(fontSize: 14, color: AppColors.textHint),
                                    prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    ReportDataTable(
                      columns: const ['Mã LH', 'Tên LH'],
                      rows: _displayedCategories
                          .skip((_currentPage - 1) * _pageSize)
                          .take(_pageSize)
                          .map((cat) => [cat.maLoai, cat.tenLoai])
                          .toList(),
                      currentPage: _currentPage,
                      totalPages: (_displayedCategories.length / _pageSize).ceil(),
                      onPageChanged: (page) => setState(() => _currentPage = page),
                      onRowTap: (index) {
                        final cat = _displayedCategories[(_currentPage - 1) * _pageSize + index];
                        _showEditCategoryDialog(cat);
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
