import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/models/customer.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/models/product.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/services/customer_service.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/services/product_service.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/services/order_service.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/component/notification_dialog.dart';

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
  final _discountController = TextEditingController(text: '0');
  final _noteController = TextEditingController();
  
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

  double get _subTotal => _cartItems.fold(0, (sum, item) => sum + item.total);
  double get _totalRevenue => _subTotal - (double.tryParse(_discountController.text) ?? 0);

  void _showAddProductDialog() {
    String? search;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredProds = _products.where((p) {
            final q = search?.toLowerCase() ?? '';
            return p.tenHH.toLowerCase().contains(q) || p.maVach.toLowerCase().contains(q);
          }).toList();

          return AlertDialog(
            title: const Text('Chọn sản phẩm'),
            content: SizedBox(
              width: 400,
              height: 500,
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => setDialogState(() => search = val),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Tìm theo tên hoặc SKU',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredProds.length,
                      itemBuilder: (context, index) {
                        final p = filteredProds[index];
                        return ListTile(
                          title: Text(p.tenHH),
                          subtitle: Text('${p.maVach} - Còn: ${p.soLuong} - ${_currencyFormat.format(p.giaBan)}'),
                          onTap: () {
                            setState(() {
                              final existing = _cartItems.indexWhere((i) => i.product.id == p.id);
                              if (existing >= 0) {
                                _cartItems[existing].quantity++;
                              } else {
                                _cartItems.add(CartItem(product: p));
                              }
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSelectCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn khách hàng'),
        content: SizedBox(
          width: 350,
          height: 400,
          child: ListView.builder(
            itemCount: _customers.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Khách lẻ'),
                  onTap: () {
                    setState(() => _selectedCustomer = null);
                    Navigator.pop(context);
                  },
                );
              }
              final c = _customers[index - 1];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(c.tenKH),
                subtitle: Text(c.sdt),
                onTap: () {
                  setState(() => _selectedCustomer = c);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (_cartItems.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final res = await OrderService.createOrder(
        customerId: _selectedCustomer?.id,
        customerName: _selectedCustomer?.tenKH ?? 'Khách lẻ',
        items: _cartItems.map((i) => {
          'MaHH': i.product.id,
          'SoLuongBan': i.quantity,
          'discount': i.discount,
        }).toList(),
        ChietKhau: double.tryParse(_discountController.text) ?? 0,
        paymentMethod: 'cash',
        note: _noteController.text,
      );

      setState(() => _isLoading = false);
      if (res['success'] == true) {
        if (mounted) {
          NotificationDialog.showSuccess(context, 'Tạo đơn hàng thành công!');
          Navigator.pop(context, true);
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
        title: const Text('THÊM HÓA ĐƠN BÁN HÀNG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                      // Customer Section
                      _buildSectionHeader('Khách hàng'),
                      InkWell(
                        onTap: _showSelectCustomerDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(_selectedCustomer?.tenKH ?? 'Khách lẻ', 
                                  style: const TextStyle(fontWeight: FontWeight.w500)),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Products Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader('Sản phẩm đã chọn'),
                          TextButton.icon(
                            onPressed: _showAddProductDialog,
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Thêm SP'),
                          ),
                        ],
                      ),
                      if (_cartItems.isEmpty)
                        const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Chưa có sản phẩm nào')))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            return _buildCartItem(item, index);
                          },
                        ),
                      
                      const SizedBox(height: 24),
                      _buildSectionHeader('Ghi chú'),
                      TextField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Nhập ghi chú cho đơn hàng',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Billing Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))],
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Tiền hàng:', _currencyFormat.format(_subTotal)),
                    _buildSummaryRow('Giảm giá:', '', 
                      customValueWidget: SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _discountController,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow('TỔNG THANH TOÁN:', _currencyFormat.format(_totalRevenue), 
                      isTotal: true),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('XÁC NHẬN BÁN HÀNG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
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

  Widget _buildCartItem(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.tenHH, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${item.product.maVach} - ${_currencyFormat.format(item.product.giaBan)}', 
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: () => setState(() => item.quantity > 1 ? item.quantity-- : _cartItems.removeAt(index)), 
                icon: const Icon(Icons.remove_circle_outline, size: 20)),
              Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => setState(() => item.quantity++), icon: const Icon(Icons.add_circle_outline, size: 20)),
            ],
          ),
          SizedBox(
            width: 80,
            child: Text(_currencyFormat.format(item.total), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Widget? customValueWidget}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14)),
          customValueWidget ?? Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, 
            fontSize: isTotal ? 16 : 14, color: isTotal ? AppColors.primary : null)),
        ],
      ),
    );
  }
}

class CartItem {
  final Product product;
  int quantity;
  double discount;

  CartItem({required this.product, this.quantity = 1, this.discount = 0});

  double get total => (product.giaBan * quantity) - discount;
}
