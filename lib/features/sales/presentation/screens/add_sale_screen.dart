import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectmobile_nhom2_conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2_conu_bookstore/core/models/customer.dart';
import 'package:projectmobile_nhom2_conu_bookstore/core/models/product.dart';
import 'package:projectmobile_nhom2_conu_bookstore/core/services/customer_service.dart';
import 'package:projectmobile_nhom2_conu_bookstore/core/services/product_service.dart';
import 'package:projectmobile_nhom2_conu_bookstore/core/services/order_service.dart';
import 'package:projectmobile_nhom2_conu_bookstore/features/component/notification_dialog.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  
  List<Customer> _customers = [];
  List<Product> _products = [];
  Customer? _selectedCustomer;
  final List<CartItem> _cartItems = [];
  final _phoneController = TextEditingController();
  final _customerIdController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _invoiceIdController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _noteController = TextEditingController();
  final _productSearchController = TextEditingController();
  String _paymentMethod = 'Tiền mặt';
  bool _isLoading = false;
  List<Product> _productSuggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _fetchNextInvoiceCode();
    _fetchData();
  }

  void _generateInvoiceId() {
    final now = DateTime.now();
    final datePart = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    _invoiceIdController.text = 'HDB${datePart}001';
  }

  Future<void> _fetchNextInvoiceCode() async {
    try {
      final nextCode = await OrderService.getNextOrderCode();
      setState(() => _invoiceIdController.text = nextCode);
    } catch (_) {
      _generateInvoiceId();
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        CustomerService.getAllCustomers(),
        ProductService.getAllProducts(),
      ]);
      setState(() {
        _customers = results[0] as List<Customer>;
        _products = results[1] as List<Product>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi tải dữ liệu bán hàng')));
      }
    }
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
      final customer = _customers.firstWhere((c) => c.sdt == phone);
      setState(() {
        _selectedCustomer = customer;
        _customerIdController.text = customer.maKH;
        _customerNameController.text = customer.tenKH;
        _customerAddressController.text = customer.diaChi;
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

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 450,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
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
                          'THÊM KHÁCH HÀNG MỚI',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
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
                      _buildCustomerDialogTextField('Tên khách hàng:', nameController),
                      const SizedBox(height: 16),
                      _buildCustomerDialogTextField('Số điện thoại:', phoneController, keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildCustomerDialogTextField('Địa chỉ:', addressController),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Hủy'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Vui lòng nhập tên và số điện thoại')),
                                  );
                                  return;
                                }
                                final newCustomer = Customer(
                                  id: '',
                                  maKH: '',
                                  tenKH: nameController.text,
                                  sdt: phoneController.text,
                                  diaChi: addressController.text,
                                );
                                final response = await CustomerService.createCustomer(newCustomer);
                                if (response['success'] == true) {
                                  final createdCustomer = Customer.fromJson(response['data']);
                                  setState(() {
                                    _customers.add(createdCustomer);
                                    _selectedCustomer = createdCustomer;
                                    _phoneController.text = createdCustomer.sdt;
                                    _customerIdController.text = createdCustomer.maKH;
                                    _customerNameController.text = createdCustomer.tenKH;
                                    _customerAddressController.text = createdCustomer.diaChi;
                                  });
                                  Navigator.pop(context);
                                  if (mounted) {
                                    NotificationDialog.showSuccess(context, 'Thêm khách hàng thành công!');
                                  }
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(response['message'] ?? 'Lỗi thêm khách hàng')),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
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
        ),
      ),
    );
  }

  Widget _buildCustomerDialogTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      return p.tenHH.toLowerCase().contains(query.toLowerCase()) ||
             p.maVach.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() => _productSuggestions = filtered);
  }

  void _selectProduct(Product product) {
    setState(() {
      _productSearchController.text = product.tenHH;
      _productSuggestions = [];
      _showSuggestions = false;
    });
  }

  void _addProductToCart() {
    if (_productSearchController.text.isEmpty) return;

    try {
      final product = _products.firstWhere((p) =>
          p.tenHH.toLowerCase() == _productSearchController.text.toLowerCase() ||
          p.maVach.toLowerCase() == _productSearchController.text.toLowerCase());

      setState(() {
        final existing = _cartItems.indexWhere((i) => i.product.id == product.id);
        if (existing >= 0) {
          _cartItems[existing].quantity++;
        } else {
          _cartItems.add(CartItem(product: product));
        }
        _productSearchController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sản phẩm không tồn tại')));
    }
  }

  double get _subTotal => _cartItems.fold(0, (sum, item) => sum + item.total);
  double get _maxDiscount => _subTotal * 0.1;
  double get _totalRevenue => _subTotal - (double.tryParse(_discountController.text) ?? 0);

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác Nhận Hủy'),
        content: const Text('Bạn có chắc muốn hủy tạo hóa đơn?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Không')),
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
    final discount = double.tryParse(_discountController.text) ?? 0;
    if (discount > _maxDiscount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chiết khấu không được vượt quá ${_currencyFormat.format(_maxDiscount)}')),
      );
      return;
    }

    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm sản phẩm')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await OrderService.createOrder(
        customerId: _selectedCustomer?.id,
        customerName: _selectedCustomer?.tenKH ?? 'Khách lẻ',
        items: _cartItems.map((i) => {
          'MaHH': i.product.id,
          'SoLuongBan': i.quantity,
          'discount': 0,
        }).toList(),
        chietKhau: discount,
        paymentMethod: _paymentMethod == 'Tiền mặt' ? 'cash' : 'transfer',
        note: _noteController.text,
      );

      setState(() => _isLoading = false);
      if (res['success'] == true) {
        if (mounted) {
          NotificationDialog.showSuccess(context, 'Tạo đơn hàng thành công!');
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context, true);
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Lỗi tạo đơn hàng')));
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BÁN HÀNG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thông tin khách hàng
                      _buildSectionHeader('Thông Tin Khách Hàng'),
                      
                      _buildLabel('Số Điện Thoại'),
                      TextField(
                        controller: _phoneController,
                        onChanged: _searchCustomerByPhone,
                        decoration: _buildInputDecoration(''),
                      ),
                      const SizedBox(height: 12),
                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showAddCustomerDialog,
                          child: const Text('Thêm khách hàng mới'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('Mã Khách Hàng:'),
                      TextField(
                        controller: _customerIdController,
                        readOnly: true,
                        decoration: _buildDisabledInputDecoration(''),
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('Tên Khách Hàng:'),
                      TextField(
                        controller: _customerNameController,
                        readOnly: true,
                        decoration: _buildDisabledInputDecoration(''),
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('Địa Chỉ:'),
                      TextField(
                        controller: _customerAddressController,
                        readOnly: true,
                        decoration: _buildDisabledInputDecoration(''),
                      ),
                      const SizedBox(height: 24),

                      // Thông tin hóa đơn
                      _buildSectionHeader('Thông Tin Hóa Đơn'),
                      
                      _buildLabel('Mã Hóa Đơn:'),
                      TextField(
                        controller: _invoiceIdController,
                        readOnly: true,
                        decoration: _buildDisabledInputDecoration(''),
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('Ngày Bán:'),
                      TextField(
                        readOnly: true,
                        controller: TextEditingController(text: DateFormat('dd/MM/yyyy').format(DateTime.now())),
                        decoration: _buildDisabledInputDecoration(''),
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('Hình Thức Thanh Toán:'),
                      DropdownButtonFormField<String>(
                        initialValue: _paymentMethod,
                        items: ['Tiền mặt', 'Chuyển khoản']
                            .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _paymentMethod = val);
                          }
                        },
                        decoration: _buildInputDecoration(''),
                      ),
                      const SizedBox(height: 24),

                      // Sản phẩm
                      _buildSectionHeader('Sản Phẩm'),
                      _buildLabel('Nhập tên hoặc mã hàng hóa'),
                      
                      TextField(
                        controller: _productSearchController,
                        onChanged: _searchProducts,
                        onTap: () => setState(() => _showSuggestions = true),
                        decoration: _buildInputDecoration('Tìm sản phẩm...'),
                      ),
                      
                      if (_showSuggestions && _productSuggestions.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF0E567C)),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _productSuggestions.length,
                            itemBuilder: (context, index) {
                              final p = _productSuggestions[index];
                              return ListTile(
                                dense: true,
                                title: Text(p.tenHH),
                                subtitle: Text('${p.maVach} - ${_currencyFormat.format(p.giaBan)}'),
                                onTap: () => _selectProduct(p),
                              );
                            },
                          ),
                        ),
                      
                      const SizedBox(height: 12),
                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _addProductToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),
                          child: const Text('THÊM', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_cartItems.isNotEmpty) ...[
                        _buildCartTableHeader(),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) => _buildCartRow(_cartItems[index], index),
                        ),
                      ] else
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'Chưa có sản phẩm nào được chọn',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      _buildSectionHeader('Ghi Chú'),
                      TextField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: _buildInputDecoration('Nhập ghi chú cho đơn hàng'),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // Tổng tiền
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    _buildTotalRow('Tổng Tiền Hàng:', _currencyFormat.format(_subTotal)),
                    const SizedBox(height: 12),
                    _buildLabel('Chiết Khấu:'),
                    TextField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: _buildInputDecoration('Chiết khấu tối đa: ${_currencyFormat.format(_maxDiscount)}'),
                    ),
                    const SizedBox(height: 12),
                    _buildTotalRow('Tổng Thành Tiền:', _currencyFormat.format(_totalRevenue), isTotal: true),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showCancelDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('HỦY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('THANH TOÁN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFF0E567C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFF0E567C)),
      ),
      contentPadding: const EdgeInsets.all(12),
    );
  }

  InputDecoration _buildDisabledInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFE5E7EB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(12),
    );
  }

  Widget _buildCartTableHeader() {
    return Row(
      children: [
        const Expanded(flex: 2, child: Text('Mã hàng hóa', style: TextStyle(fontWeight: FontWeight.bold))),
        const Expanded(flex: 1, child: Text('Số lượng', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
        const Expanded(flex: 1, child: Text('Thành tiền', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
      ],
    );
  }

  Widget _buildCartRow(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0E567C)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.tenHH, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(item.product.maVach, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF0E567C)),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      iconSize: 18,
                      padding: const EdgeInsets.all(4),
                      onPressed: () => setState(() {
                        if (item.quantity > 1) {
                          item.quantity--;
                        } else {
                          _cartItems.removeAt(index);
                        }
                      }),
                      icon: const Icon(Icons.remove),
                    ),
                    Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      iconSize: 18,
                      padding: const EdgeInsets.all(4),
                      onPressed: () => setState(() => item.quantity++),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              _currencyFormat.format(item.total),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14)),
        Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14, color: isTotal ? AppColors.primary : null)),
      ],
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
    _noteController.dispose();
    _productSearchController.dispose();
    super.dispose();
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.giaBan * quantity;
}
