import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/utils/formatters.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/data/datasources/customer_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/data/models/customer_model.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/data/datasources/product_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/data/models/product_model.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/data/datasources/order_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/injection_container.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  List<CustomerModel> _customers = [];
  List<ProductModel> _products = [];
  CustomerModel? _selectedCustomer;
  final List<CartItem> _cartItems = [];
  final _phoneController = TextEditingController();
  final _customerIdController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _invoiceIdController = TextEditingController();
  final _discountController = TextEditingController();
  final _productSearchController = TextEditingController();
  String _paymentMethod = 'Tiền mặt';
  bool _isLoading = false;
  List<ProductModel> _productSuggestions = [];
  bool _showSuggestions = false;
  final FocusNode _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchNextInvoiceCode();
    _fetchData();
  }

  void _generateInvoiceId() {
    final now = DateTime.now();
    final datePart = DateFormat('yyyyMMddHHmm').format(now);
    _invoiceIdController.text = 'HDB$datePart';
  }

  Future<void> _fetchNextInvoiceCode() async {
    try {
      final nextCode = await sl<OrderRemoteDataSource>().getNextOrderCode();
      setState(() => _invoiceIdController.text = nextCode);
    } catch (_) {
      _generateInvoiceId();
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        sl<CustomerRemoteDataSource>().getAllCustomers(),
        sl<ProductRemoteDataSource>().getAllProducts(),
      ]);
      setState(() {
        _customers = results[0] as List<CustomerModel>;
        _products = results[1] as List<ProductModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi tải dữ liệu bán hàng')),
        );
      }
    }
  }

  void _onCustomerSelected(CustomerModel customer) {
    setState(() {
      _selectedCustomer = customer;
      _phoneController.text = customer.phone;
      _customerIdController.text = customer.code;
      _customerNameController.text = customer.name;
      _customerAddressController.text = customer.address ?? '';
    });
  }

  void _searchCustomerByPhone(String phone) {
    if (phone.isEmpty) {
      setState(() {
        _selectedCustomer = null;
        _customerIdController.clear();
        _customerNameController.clear();
        _customerAddressController.clear();
      });
      return;
    }
    try {
      final customer = _customers.firstWhere((c) => c.phone == phone);
      setState(() {
        _selectedCustomer = customer;
        _customerIdController.text = customer.code;
        _customerNameController.text = customer.name;
        _customerAddressController.text = customer.address ?? '';
      });
    } catch (e) {
      setState(() {
        _selectedCustomer = null;
        _customerIdController.clear();
        _customerNameController.clear();
        _customerAddressController.clear();
      });
    }
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    bool isSaving = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 450,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'THÊM KHÁCH HÀNG MỚI',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          GestureDetector(
                            onTap: isSaving
                                ? null
                                : () => Navigator.pop(context),
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCustomerDialogTextField(
                            'Tên khách hàng:',
                            nameController,
                          ),
                          const SizedBox(height: 16),
                          _buildCustomerDialogTextField(
                            'Số điện thoại:',
                            phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _buildCustomerDialogTextField(
                            'Địa chỉ:',
                            addressController,
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isSaving
                                      ? null
                                      : () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.primary,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text('Hủy'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isSaving
                                      ? null
                                      : () async {
                                          final name = nameController.text
                                              .trim();
                                          final phone = phoneController.text
                                              .trim();
                                          if (name.isEmpty || phone.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Vui lòng nhập tên và số điện thoại',
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          if (phone.length != 10 ||
                                              !RegExp(
                                                r'^[0-9]+$',
                                              ).hasMatch(phone)) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Số điện thoại phải có đúng 10 chữ số',
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          setDialogState(() => isSaving = true);
                                          try {
                                            int maxId = 0;
                                            for (var c in _customers) {
                                              if (c.code.startsWith('KH')) {
                                                final numPart =
                                                    int.tryParse(
                                                      c.code.substring(2),
                                                    ) ??
                                                    0;
                                                if (numPart > maxId)
                                                  maxId = numPart;
                                              }
                                            }
                                            final nextCode =
                                                'KH${(maxId + 1).toString().padLeft(5, '0')}';
                                            final newCustomer = CustomerModel(
                                              id: '',
                                              code: nextCode,
                                              name: name,
                                              phone: phone,
                                              address: addressController.text
                                                  .trim(),
                                            );
                                            final createdCustomer =
                                                await sl<
                                                      CustomerRemoteDataSource
                                                    >()
                                                    .createCustomer(
                                                      newCustomer,
                                                    );
                                            setState(() {
                                              _customers.add(createdCustomer);
                                              _onCustomerSelected(
                                                createdCustomer,
                                              );
                                            });
                                            if (mounted) {
                                              Navigator.pop(context);
                                              NotificationDialog.showSuccess(
                                                context,
                                                'Thêm khách hàng thành công!',
                                              );
                                            }
                                          } catch (e) {
                                            setDialogState(
                                              () => isSaving = false,
                                            );
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text('Lỗi: $e'),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: isSaving
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Lưu',
                                          style: TextStyle(color: Colors.white),
                                        ),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomerDialogTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _searchProducts(String query) {
    if (query.isEmpty) {
      setState(() => _productSuggestions = []);
      return;
    }
    final filtered = _products.where((p) {
      return p.name.toLowerCase().contains(query.toLowerCase()) ||
          p.barcode.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() => _productSuggestions = filtered);
  }

  void _selectProduct(ProductModel product) {
    setState(() {
      _productSearchController.text = product.name;
      _productSuggestions = [];
      _showSuggestions = false;
    });
  }

  void _addProductToCart() {
    if (_productSearchController.text.isEmpty) return;
    try {
      final product = _products.firstWhere(
        (p) =>
            p.name.toLowerCase() ==
                _productSearchController.text.toLowerCase() ||
            p.barcode.toLowerCase() ==
                _productSearchController.text.toLowerCase(),
      );
      setState(() {
        final existing = _cartItems.indexWhere(
          (i) => i.product.id == product.id,
        );
        if (existing >= 0) {
          _cartItems[existing].quantity++;
        } else {
          _cartItems.add(CartItem(product: product));
        }
        _productSearchController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sản phẩm không tồn tại')));
    }
  }

  double get _subTotal => _cartItems.fold(0, (sum, item) => sum + item.total);

  double get _maxDiscountPercent => 100.0;

  double get _totalRevenue =>
      _subTotal * (1 - (double.tryParse(_discountController.text) ?? 0) / 100);

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác Nhận Hủy'),
        content: const Text('Bạn có chắc muốn hủy tạo hóa đơn?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitOrder() async {
    final discountPercent = double.tryParse(_discountController.text) ?? 0;
    if (discountPercent > _maxDiscountPercent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chiết khấu không được vượt quá 100%')),
      );
      return;
    }
    final discountAmount = _subTotal * (discountPercent / 100);
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng thêm sản phẩm')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await sl<OrderRemoteDataSource>().createOrder({
        'customerId': _selectedCustomer?.id,
        'customerCode': _selectedCustomer?.code,
        'customerName': _selectedCustomer?.name ?? 'Khách lẻ',
        'items': _cartItems
            .map(
              (i) => {
                'MaHH': i.product.id,
                'SoLuongBan': i.quantity,
                'discount': 0,
              },
            )
            .toList(),
        'ChietKhau': discountAmount,
        'paymentMethod': _paymentMethod == 'Tiền mặt' ? 'cash' : 'transfer',
      });
      setState(() => _isLoading = false);
      if (mounted) {
        NotificationDialog.showSuccess(context, 'Tạo đơn hàng thành công!');
        Future.delayed(const Duration(milliseconds: 2200), () {
          if (mounted) Navigator.of(context).pop(true);
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        NotificationDialog.showError(context, 'Lỗi: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppDrawer(
        currentRoute: 'sales',
        onItemSelected: (routeId) {
          if (routeId == 'logout') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          } else if (routeId != 'sales') {
            Navigator.pop(context, routeId);
          }
        },
      ),
      appBar: AppBar(
        title: const Text(
          'BÁN HÀNG',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(
                children: [
                  _buildFieldset(
                    title: 'Thông Tin Khách Hàng',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Số Điện Thoại'),
                        RawAutocomplete<CustomerModel>(
                          textEditingController: _phoneController,
                          focusNode: _phoneFocusNode,
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<CustomerModel>.empty();
                            }
                            return _customers.where(
                              (c) => c.phone.contains(textEditingValue.text),
                            );
                          },
                          displayStringForOption: (c) => c.phone,
                          onSelected: (c) => _onCustomerSelected(c),
                          fieldViewBuilder:
                              (
                                context,
                                controller,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                return _buildInputField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  hintText: 'Nhập số điện thoại',
                                  onChanged: (val) {
                                    _searchCustomerByPhone(val);
                                  },
                                );
                              },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  width: 320,
                                  constraints: const BoxConstraints(
                                    maxHeight: 250,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final c = options.elementAt(index);
                                      return ListTile(
                                        dense: true,
                                        title: Text(
                                          c.phone,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        subtitle: Text(
                                          c.name,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        onTap: () => onSelected(c),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildLabel('Mã Khách Hàng:'),
                        _buildInputField(
                          controller: _customerIdController,
                          readOnly: true,
                        ),
                        const SizedBox(height: 12),
                        _buildLabel('Tên Khách Hàng:'),
                        _buildInputField(
                          controller: _customerNameController,
                          readOnly: true,
                        ),
                        const SizedBox(height: 12),
                        _buildLabel('Địa Chỉ:'),
                        _buildInputField(
                          controller: _customerAddressController,
                          readOnly: true,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showAddCustomerDialog,
                            child: const Text(
                              'Thêm khách hàng mới',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFieldset(
                    title: 'Thông Tin Hóa Đơn',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Mã Hóa Đơn:'),
                        _buildInputField(
                          controller: _invoiceIdController,
                          readOnly: true,
                        ),
                        const SizedBox(height: 12),
                        _buildLabel('Ngày Bán:'),
                        _buildInputField(
                          controller: TextEditingController(
                            text: DateFormat(
                              'dd/MM/yyyy',
                            ).format(DateTime.now()),
                          ),
                          readOnly: true,
                        ),
                        const SizedBox(height: 12),
                        _buildLabel('HT Thanh Toán:'),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return SizedBox(
                              height: 40,
                              child: DropdownMenu<String>(
                                width: constraints.maxWidth,
                                initialSelection: _paymentMethod,
                                textStyle: const TextStyle(fontSize: 14),
                                inputDecorationTheme: InputDecorationTheme(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  constraints: const BoxConstraints(
                                    maxHeight: 40,
                                    minHeight: 40,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF0E567C),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF0E567C),
                                    ),
                                  ),
                                ),
                                onSelected: (val) {
                                  if (val != null)
                                    setState(() => _paymentMethod = val);
                                },
                                dropdownMenuEntries:
                                    ['Tiền mặt', 'Chuyển khoản'].map((m) {
                                      return DropdownMenuEntry<String>(
                                        value: m,
                                        label: m,
                                      );
                                    }).toList(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildLabel('Chiết Khấu:'),
                        _buildInputField(
                          controller: _discountController,
                          hintText: 'Nhập chiết khấu',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Tổng Thành Tiền:'),
                                  Container(
                                    height: 40,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5E7EB),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: const Color(0xFF0E567C),
                                      ),
                                    ),
                                    child: Text(
                                      AppFormatters.formatCurrencyNoSymbol(
                                        _totalRevenue,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  _buildActionButton(
                                    label: 'Hủy',
                                    color: AppColors.primary,
                                    onPressed: _showCancelDialog,
                                  ),
                                  const SizedBox(height: 4),
                                  _buildActionButton(
                                    label: 'Xác nhận thanh toán',
                                    color: AppColors.primary,
                                    onPressed: _submitOrder,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: DropdownMenu<ProductModel>(
                                      width: constraints.maxWidth - 88,
                                      hintText: 'Nhập tên hoặc mã hàng hóa',
                                      controller: _productSearchController,
                                      enableSearch: true,
                                      enableFilter: true,
                                      textStyle: const TextStyle(fontSize: 14),
                                      menuStyle: MenuStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                              Colors.white,
                                            ),
                                        elevation: WidgetStateProperty.all(8),
                                      ),
                                      inputDecorationTheme:
                                          InputDecorationTheme(
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                ),
                                            constraints: const BoxConstraints(
                                              maxHeight: 40,
                                              minHeight: 40,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF0E567C),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF0E567C),
                                              ),
                                            ),
                                          ),
                                      dropdownMenuEntries: _products
                                          .where((p) => p.status == 'active')
                                          .map((p) {
                                            return DropdownMenuEntry<
                                              ProductModel
                                            >(
                                              value: p,
                                              label: p.name,
                                              style: MenuItemButton.styleFrom(
                                                textStyle: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          })
                                          .toList(),
                                      onSelected: (p) {
                                        if (p != null) {
                                          setState(() {
                                            _productSearchController.text =
                                                p.name;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 40,
                                  width: 80,
                                  child: ElevatedButton(
                                    onPressed: _addProductToCart,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: const Text(
                                      'THÊM',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildCartTable(),
                ],
              ),
            ),
    );
  }

  Widget _buildFieldset({required String title, required Widget child}) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF0E567C), width: 1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: child,
        ),
        Positioned(
          left: 12,
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    FocusNode? focusNode,
    bool readOnly = false,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
    VoidCallback? onTap,
    Widget? prefixIcon,
  }) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onTap: onTap,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          filled: readOnly,
          fillColor: readOnly ? const Color(0xFFE5E7EB) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Color(0xFF0E567C)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Color(0xFF0E567C)),
          ),
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return SizedBox(
      height: 40,
      child: DropdownButtonFormField<String>(
        initialValue: _paymentMethod,
        items: ['Tiền mặt', 'Chuyển khoản']
            .map(
              (m) => DropdownMenuItem(
                value: m,
                child: Text(m, style: const TextStyle(fontSize: 14)),
              ),
            )
            .toList(),
        onChanged: (val) {
          if (val != null) setState(() => _paymentMethod = val);
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Color(0xFF0E567C)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Color(0xFF0E567C)),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 18,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCartTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0E567C), width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF0E567C))),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Mã hàng hóa',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Số lượng',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Thành tiền',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          if (_cartItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có sản phẩm nào được chọn',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cartItems.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFF0E567C)),
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              item.product.code,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() {
                                if (item.quantity > 1) {
                                  item.quantity--;
                                } else {
                                  _cartItems.removeAt(index);
                                }
                              }),
                              child: const Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                item.quantity.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => item.quantity++),
                              child: const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          AppFormatters.formatCurrencyNoSymbol(item.total),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _customerIdController.dispose();
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _invoiceIdController.dispose();
    _discountController.dispose();
    _productSearchController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }
}

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}
