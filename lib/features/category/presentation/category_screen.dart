import 'package:flutter/material.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/models/category.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/component/notification_dialog.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/presentation/add_category_screen.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/presentation/category_detail_screen.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/services/category_service.dart';
import '../../report/presentation/widgets/report_data_table.dart';

class CategoryScreen extends StatefulWidget {
  // Màn hình danh sách loại hàng
  // - Hiển thị các loại đang `active` (server trả về active theo mặc định)
  // - Có nút điều hướng sang màn hình thêm loại hàng riêng
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
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Gọi API để lấy danh sách loại hàng (mặc định chỉ active)
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

  // Lọc local theo từ khoá search trên mã hoặc tên
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

  void _onSearch() {
    _filterCategories();
    setState(() {
      _isSearching = _searchController.text.trim().isNotEmpty;
    });
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _displayedCategories = List.from(_allCategories);
      _currentPage = 1;
      _isSearching = false;
    });
  }

  // Mở màn hình thêm loại hàng chuyên biệt và chờ kết quả
  Future<void> _openAddCategoryScreen() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCategoryScreen(initialCategories: _allCategories),
      ),
    );

    if (created == true) {
      // Nếu có tạo mới thành công -> tải lại danh sách và show popup thành công
      await _fetchCategories();
      if (mounted) {
        NotificationDialog.showAddCategorySuccess(context);
      }
    }
  }

  // Mở chi tiết loại hàng (màn hình danh sách sản phẩm thuộc loại đó)
  void _openCategoryDetail(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryDetailScreen(
          category: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tableWidth = screenWidth * 0.9;

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
                        SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: _openAddCategoryScreen,
                            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
                            label: const Text('Thêm loại hàng', style: TextStyle(color: Colors.white, fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: TextField(
                              controller: _searchController,
                              textAlignVertical: TextAlignVertical.center,
                              style: const TextStyle(fontSize: 13, height: 1.0),
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _onSearch(),
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm',
                                hintStyle: const TextStyle(fontSize: 13, height: 1.0, color: AppColors.textHint),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Container(
                                    height: 22,
                                    width: 22,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.search, size: 12, color: Colors.white),
                                  ),
                                ),
                                suffixIconConstraints: const BoxConstraints(minHeight: 22, minWidth: 22),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSearching) ...[
                            SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: _onClearSearch,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 18),
                                ),
                                child: const Text('Hủy', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              onPressed: _onSearch,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                              ),
                              child: const Text('Tìm kiếm', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: ReportDataTable(
                        columns: const ['Mã LH', 'Tên LH'],
                        rows: _displayedCategories
                            .skip((_currentPage - 1) * _pageSize)
                            .take(_pageSize)
                            .map((cat) => [cat.maLoai, cat.tenLoai])
                            .toList(),
                        currentPage: _currentPage,
                        totalPages: (_displayedCategories.length / _pageSize).ceil(),
                        tableWidth: tableWidth,
                        onPageChanged: (page) => setState(() => _currentPage = page),
                        onRowTap: (index) {
                          final cat = _displayedCategories[(_currentPage - 1) * _pageSize + index];
                          _openCategoryDetail(cat);
                        },
                      ),
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
