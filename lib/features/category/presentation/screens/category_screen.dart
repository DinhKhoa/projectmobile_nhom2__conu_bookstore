import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/domain/entities/category_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/presentation/bloc/category_bloc.dart';

import '../../../report/presentation/widgets/report_data_table.dart';
import 'add_category_screen.dart';
import 'category_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _appliedSearchQuery = '';
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategoriesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: BlocConsumer<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state is CategoryError) {
              NotificationDialog.showError(context, state.message);
            }
            if (state is CategoryActionSuccess) {
              NotificationDialog.showSuccess(context, state.message);
            }
          },
          builder: (context, state) {
            List<CategoryEntity> categories = [];
            bool isLoading = false;
            if (state is CategoryLoading) {
              isLoading = true;
            } else if (state is CategoryLoaded) {
              categories = state.categories;
            }
            final query = _appliedSearchQuery.toLowerCase();
            final filteredCategories = categories.where((cat) {
              return cat.code.toLowerCase().contains(query) ||
                  cat.name.toLowerCase().contains(query);
            }).toList();
            return RefreshIndicator(
              onRefresh: () async {
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
                      'DANH SÁCH LOẠI HÀNG',
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
                                  builder: (innerContext) => BlocProvider.value(
                                    value: BlocProvider.of<CategoryBloc>(
                                      context,
                                    ),
                                    child: const AddCategoryScreen(),
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
                              'Thêm loại hàng',
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
                    if (isLoading && categories.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else
                      ReportDataTable(
                        columns: const ['Mã LH', 'Tên LH'],
                        rows: filteredCategories
                            .skip((_currentPage - 1) * _pageSize)
                            .take(_pageSize)
                            .map((cat) => [cat.code, cat.name])
                            .toList(),
                        currentPage: _currentPage,
                        totalPages: (filteredCategories.length / _pageSize)
                            .ceil()
                            .clamp(1, double.infinity)
                            .toInt(),
                        onPageChanged: (page) =>
                            setState(() => _currentPage = page),
                        onRowTap: (index) {
                          final cat =
                              filteredCategories[(_currentPage - 1) *
                                      _pageSize +
                                  index];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CategoryDetailScreen(category: cat),
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
