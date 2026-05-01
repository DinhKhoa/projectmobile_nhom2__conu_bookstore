import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/domain/entities/category_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/presentation/bloc/product_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/presentation/bloc/product_event.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/presentation/bloc/product_state.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/presentation/widgets/report_data_table.dart';

class CategoryDetailScreen extends StatelessWidget {
  final CategoryEntity category;
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    context.read<ProductBloc>().add(LoadProductsRequested());
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.cancel_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                'Danh sách hàng hóa',
                style: AppTextStyles.subHeading.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }
                if (state is ProductsLoaded) {
                  final categoryProducts = state.products
                      .where((p) => p.categoryId == category.id)
                      .toList();
                  if (categoryProducts.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Text(
                          'Chưa có hàng hóa nào trong loại này',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ReportDataTable(
                      columns: const ['Mã HH', 'Tên hàng hóa', 'Giá bán'],
                      rows: categoryProducts.map((p) {
                        return [
                          p.code,
                          p.name,
                          _currencyFormat.format(p.price),
                        ];
                      }).toList(),
                    ),
                  );
                }
                if (state is ProductFailure) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
