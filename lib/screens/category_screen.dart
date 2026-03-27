import 'package:flutter/material.dart';
import '../core/core.dart';
import '../widgets/widgets.dart';

class CategoryInfo {
  final String id;
  final String name;

  CategoryInfo(this.id, this.name);
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<CategoryInfo> _allCategories = [
    CategoryInfo('LH001', 'Sách giáo khoa'),
    CategoryInfo('LH002', 'Vở'),
    CategoryInfo('LH003', 'Bút'),
    CategoryInfo('LH004', 'Dụng cụ học sinh'),
    CategoryInfo('LH005', 'Vở'),
    CategoryInfo('LH006', 'Balo'),
    CategoryInfo('LH007', 'Giấy'),
    CategoryInfo('LH008', 'Sách bài tập'),
    CategoryInfo('LH009', 'Thiết bị văn phòng'),
    CategoryInfo('LH010', 'Đồ chơi'),
  ];

  late List<CategoryInfo> _displayedCategories;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _displayedCategories = List.from(_allCategories);
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
          return category.id.toLowerCase().contains(query) ||
              category.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  String get _nextCategoryId {
    if (_allCategories.isEmpty) return 'LH001';
    int maxIndex = 0;
    for (var cat in _allCategories) {
      if (cat.id.startsWith('LH')) {
        int? numPart = int.tryParse(cat.id.substring(2));
        if (numPart != null && numPart > maxIndex) maxIndex = numPart;
      }
    }
    return 'LH${(maxIndex + 1).toString().padLeft(3, '0')}';
  }

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title Area
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        child: const Icon(Icons.cancel_outlined, color: Colors.white),
                      )
                    ],
                  ),
                ),
                // Content Area
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Thông Tin Loại Hàng:',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        const Text('Mã LH:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: 'Mã tự động',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Tên LH:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              ),
                              child: const Text('Hủy', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (nameController.text.trim().isNotEmpty) {
                                  setState(() {
                                    _allCategories.add(CategoryInfo(_nextCategoryId, nameController.text.trim()));
                                    _filterCategories();
                                  });
                                  Navigator.pop(context);
                                  _showSuccessDialog();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              ),
                              child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.notifications, color: AppColors.primary, size: 48),
                    Positioned(
                      top: 18,
                      child: Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Thêm Mới Loại Hàng\nThành Công!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'DANH SÁCH LOẠI HÀNG',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Toolbar (Add button and Search)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add Button
                    ElevatedButton.icon(
                      onPressed: _showAddCategoryDialog,
                      icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                      label: const Text('Thêm loại hàng', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    
                    // Search Bar & Search Button Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Search TextField
                          SizedBox(
                            height: 40,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm',
                                hintStyle: const TextStyle(fontSize: 14),
                                prefixIcon: const Icon(Icons.search, size: 20),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: AppColors.primary),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: AppColors.primary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Search Button
                          ElevatedButton(
                            onPressed: _filterCategories,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            ),
                            child: const Text('Tìm kiếm', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Data Table
                Center(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent, // Hide inner divider lines to match image
                    ),
                    child: DataTable(
                      headingRowHeight: 40,
                      dataRowMinHeight: 40,
                      dataRowMaxHeight: 40,
                      headingRowColor: MaterialStateProperty.all(Colors.grey[300]),
                      columnSpacing: 60,
                      columns: const [
                        DataColumn(
                          label: Text('Mã LH', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Tên LH', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                      rows: List<DataRow>.generate(
                        _displayedCategories.length,
                        (index) {
                          final category = _displayedCategories[index];
                          final isEven = index % 2 == 0;
                          return DataRow(
                            color: MaterialStateProperty.all(
                              isEven ? Colors.transparent : Colors.blueGrey[50], // Alternating row color
                            ),
                            cells: [
                              DataCell(Text(category.id)),
                              DataCell(Text(category.name)),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
