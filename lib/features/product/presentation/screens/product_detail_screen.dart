import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/domain/entities/category_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/presentation/bloc/category_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/domain/entities/product_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/presentation/bloc/product_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/presentation/bloc/product_event.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductEntity? product;
  final List<ProductEntity>? allProducts;

  const ProductDetailScreen({super.key, this.product, this.allProducts});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _minStockController;
  late TextEditingController _profitController;
  String? _selectedCategoryId;
  bool _isActive = true;
  bool _isChanged = false;
  late bool _isEdit;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _categoryFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isEdit = widget.product != null;
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _barcodeController = TextEditingController(
      text: widget.product?.barcode ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '0',
    );
    _quantityController = TextEditingController(
      text: widget.product?.quantity.toString() ?? '0',
    );
    _unitController = TextEditingController(text: widget.product?.unit ?? '');
    _minStockController = TextEditingController(
      text: widget.product?.minStock.toString() ?? '5',
    );
    _profitController = TextEditingController(
      text: '${widget.product?.profit ?? 0}%',
    );
    _selectedCategoryId = widget.product?.categoryId;
    _isActive = widget.product?.status == 'active';
    _nameController.addListener(_checkChanges);
    _barcodeController.addListener(_checkChanges);
    _priceController.addListener(_checkChanges);
    _quantityController.addListener(_checkChanges);
    _unitController.addListener(_checkChanges);
    _minStockController.addListener(_checkChanges);
    _profitController.addListener(_checkChanges);
    if (!_isEdit) {
      _isChanged = true;
    }
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_categoryFocusNode.hasFocus) {
      _categoryFocusNode.unfocus();
    }
  }

  void _checkChanges() {
    if (!_isEdit) {
      final hasInput =
          _nameController.text.isNotEmpty || _barcodeController.text.isNotEmpty;
      if (hasInput != _isChanged) setState(() => _isChanged = hasInput);
      return;
    }
    final String cleanProfit = _profitController.text.replaceAll('%', '');
    final double? currentProfit = double.tryParse(cleanProfit);
    final changed =
        _nameController.text != widget.product!.name ||
        _barcodeController.text != widget.product!.barcode ||
        double.tryParse(_priceController.text) != widget.product!.price ||
        int.tryParse(_quantityController.text) != widget.product!.quantity ||
        _unitController.text != widget.product!.unit ||
        int.tryParse(_minStockController.text) != widget.product!.minStock ||
        currentProfit != widget.product!.profit ||
        _selectedCategoryId != widget.product!.categoryId ||
        _isActive != (widget.product!.status == 'active');
    if (changed != _isChanged) {
      setState(() {
        _isChanged = changed;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _minStockController.dispose();
    _profitController.dispose();
    _scrollController.dispose();
    _categoryFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        title: const Text(
          'THÔNG TIN HÀNG HÓA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.cancel_outlined,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          final categories = state is CategoryLoaded
              ? state.categories
              : <CategoryEntity>[];
          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const Text(
                  'Thông Tin Hàng Hóa:',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black87),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Mã hàng hóa:'),
                      const SizedBox(height: 8),
                      _buildReadOnlyField(
                        _isEdit ? widget.product!.code : 'Mã được tạo tự động',
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Tên HH:'),
                      const SizedBox(height: 8),
                      _buildEditableField(_nameController, 'Nhập tên hàng hóa'),
                      const SizedBox(height: 16),
                      _buildLabel('Mã vạch:'),
                      const SizedBox(height: 8),
                      _buildEditableField(_barcodeController, 'Nhập mã vạch'),
                      const SizedBox(height: 16),
                      _buildLabel('Tên LH:'),
                      const SizedBox(height: 8),
                      _buildCategoryDropdown(categories),
                      const SizedBox(height: 16),
                      _buildLabel('Số lượng:'),
                      const SizedBox(height: 8),
                      _buildEditableField(
                        _quantityController,
                        '0',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Đơn vị tính:'),
                      const SizedBox(height: 8),
                      _buildEditableField(_unitController, 'Cái/Cây/Quyển...'),
                      const SizedBox(height: 16),
                      _buildLabel('Ngưỡng cảnh báo:'),
                      const SizedBox(height: 8),
                      _buildEditableField(
                        _minStockController,
                        '5',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Giá bán:'),
                      const SizedBox(height: 8),
                      _buildEditableField(
                        _priceController,
                        '0',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Phần trăm lợi nhuận:'),
                      const SizedBox(height: 8),
                      _buildEditableField(_profitController, '0%'),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Switch(
                            value: _isActive,
                            onChanged: (val) {
                              setState(() => _isActive = val);
                              _checkChanges();
                            },
                            activeTrackColor: AppColors.primary,
                            activeThumbColor: Colors.white,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey[300],
                          ),
                          Text(
                            _isActive ? 'Đang hoạt động' : 'Ngừng hoạt động',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_isEdit) ...[
                      _buildActionButton(
                        onPressed: () {
                          NotificationDialog.showConfirm(
                            context,
                            'Xác nhận xóa',
                            'Bạn có chắc chắn muốn xóa sản phẩm này?',
                            () {
                              context.read<ProductBloc>().add(
                                DeleteProductRequested(widget.product!.id),
                              );
                              Navigator.pop(context);
                            },
                          );
                        },
                        label: 'Xóa',
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 16),
                    ],
                    _buildActionButton(
                      onPressed: _isChanged ? _onSave : null,
                      label: 'Lưu',
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên hàng hóa không được để trống')),
      );
      return;
    }
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn loại hàng')));
      return;
    }
    final String cleanProfit = _profitController.text.replaceAll('%', '');
    final double profitVal = double.tryParse(cleanProfit) ?? 0;
    final newProduct = ProductEntity(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      code: widget.product?.code ?? '',
      barcode: _barcodeController.text.trim(),
      categoryId: _selectedCategoryId ?? '',
      price: double.tryParse(_priceController.text) ?? 0,
      profit: profitVal,
      quantity: int.tryParse(_quantityController.text) ?? 0,
      unit: _unitController.text.trim(),
      minStock: int.tryParse(_minStockController.text) ?? 5,
      status: _isActive ? 'active' : 'inactive',
    );
    if (_isEdit) {
      context.read<ProductBloc>().add(
        UpdateProductRequested(widget.product!.id, newProduct),
      );
    } else {
      context.read<ProductBloc>().add(CreateProductRequested(newProduct));
    }
    Navigator.pop(context);
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Widget _buildReadOnlyField(String value) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        style: const TextStyle(color: Colors.black54, fontSize: 14),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFE5E7EB),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Colors.black87),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Colors.black87),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(List<CategoryEntity> categories) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 40,
          child: DropdownMenu<String>(
            focusNode: _categoryFocusNode,
            initialSelection: _selectedCategoryId,
            width: constraints.maxWidth,
            hintText: 'Chọn loại hàng',
            textStyle: const TextStyle(fontSize: 14),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              elevation: WidgetStateProperty.all(8),
            ),
            inputDecorationTheme: InputDecorationTheme(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              constraints: const BoxConstraints(maxHeight: 40, minHeight: 40),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.black87),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            onSelected: (val) {
              setState(() => _selectedCategoryId = val);
              _checkChanges();
            },
            dropdownMenuEntries: categories.map((cat) {
              return DropdownMenuEntry<String>(
                value: cat.id,
                label: cat.name,
                style: MenuItemButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required String label,
    required Color color,
  }) {
    final bool disabled = onPressed == null;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: disabled ? Colors.grey[300] : color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: disabled ? 0 : 2,
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
