import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/models/category.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/services/category_service.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/component/notification_dialog.dart';

class AddCategoryScreen extends StatefulWidget {
  final List<Category> initialCategories;

  const AddCategoryScreen({
    super.key,
    required this.initialCategories,
  });

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSubmitting = false;
  String _autoCode = 'L001';

  @override
  void initState() {
    super.initState();
    _autoCode = _generateNextCode(widget.initialCategories);
    _refreshAutoCode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int _extractCodeNumber(String code) {
    final match = RegExp(r'^L(\d+)$', caseSensitive: false).firstMatch(code.trim());
    if (match == null) {
      return 0;
    }
    return int.tryParse(match.group(1) ?? '') ?? 0;
  }

  String _generateNextCode(List<Category> categories) {
    // Sinh mã kế tiếp dựa trên giá trị Lxxx lớn nhất hiện có
    final maxIndex = categories.fold<int>(0, (maxValue, category) {
      final current = _extractCodeNumber(category.maLoai);
      return math.max(maxValue, current);
    });

    return 'L${(maxIndex + 1).toString().padLeft(3, '0')}';
  }

  Future<void> _refreshAutoCode() async {
    // Lấy tất cả (bao gồm inactive) để tránh tái sử dụng mã đã tồn tại
    final allCategories = await CategoryService.getAllCategories(includeInactive: true);
    if (!mounted || allCategories.isEmpty) {
      return;
    }

    setState(() {
      _autoCode = _generateNextCode(allCategories);
    });
  }

  bool _isDuplicateResponse(Map<String, dynamic> response) {
    // Handle duplicate indicators from multiple backend message formats.
    final statusCode = response['statusCode'];
    final message = (response['message'] ?? '').toString().toLowerCase();

    if (statusCode == 409) {
      return true;
    }

    return message.contains('đã tồn tại') ||
        message.contains('da ton tai') ||
        message.contains('trùng') ||
        message.contains('duplicate');
  }

  void _showDuplicatePopup() {
    showDialog(
      context: context,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        return const NotificationDialog(
          title: 'Đã có loại hàng này',
          message: '',
          icon: Icons.info_outline,
          iconColor: AppColors.primary,
        );
      },
    );
  }

  Future<void> _onSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _isSubmitting) {
      return;
    }

    // Kiểm tra trùng tên loại hàng (không phân biệt hoa thường)
    final isDuplicate = widget.initialCategories.any(
      (cat) => cat.tenLoai.toLowerCase() == name.toLowerCase()
    );

    if (isDuplicate) {
      _showDuplicatePopup();
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = Category(
      id: '',
      maLoai: _autoCode,
      tenLoai: name,
      trangThai: 'active',
    );

    // API may create new or reactivate inactive duplicate.
    final result = await CategoryService.createCategory(payload);
    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      Navigator.pop(context, true);
      return;
    }

    if (_isDuplicateResponse(result)) {
      _showDuplicatePopup();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text((result['message'] ?? 'Không thể thêm loại hàng').toString())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CommonAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'DANH SÁCH LOẠI HÀNG',
                  style: AppTextStyles.subHeading.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                      onTap: () => Navigator.pop(context, false),
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
                    )
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Tiêu đề form thông tin
              const Center(
                child: Text(
                  'Thông Tin Loại Hàng:',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF1C1C1C)),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Mã loại (khóa, không sửa)
                        Text('Mã LH:', style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          enabled: false,
                          controller: TextEditingController(text: _autoCode),
                          decoration: InputDecoration(
                            hintText: 'Mã tự động',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F3F3),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Tên loại (bắt buộc)
                        Text('Tên LH:', style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Đồ chơi',
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
                              child: OutlinedButton(
                                onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Hủy'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _onSave,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('Lưu', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
