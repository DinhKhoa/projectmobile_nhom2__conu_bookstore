import 'package:flutter/material.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/utils/formatters.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/data/models/order_model.dart';

class SaleDetailScreen extends StatelessWidget {
  final OrderModel order;

  const SaleDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'CHI TIẾT HÓA ĐƠN',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            _buildFieldset(
              title: 'Thông Tin Khách Hàng',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Số Điện Thoại'),
                  _buildInputField(
                    controller: TextEditingController(
                      text: order.customerPhone ?? 'Khách lẻ',
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('Mã Khách Hàng:'),
                  _buildInputField(
                    controller: TextEditingController(
                      text: order.customerCode ?? '---',
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('Tên Khách Hàng:'),
                  _buildInputField(
                    controller: TextEditingController(text: order.customerName),
                    readOnly: true,
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('Địa Chỉ:'),
                  _buildInputField(
                    controller: TextEditingController(
                      text: order.customerAddress ?? '---',
                    ),
                    readOnly: true,
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
                    controller: TextEditingController(text: order.id ?? '---'),
                    readOnly: true,
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('Ngày Bán:'),
                  _buildInputField(
                    controller: TextEditingController(
                      text: order.createdAt != null
                          ? AppFormatters.formatDate(order.createdAt!)
                          : '---',
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('HT Thanh Toán:'),
                  _buildInputField(
                    controller: TextEditingController(
                      text: order.paymentMethod == 'cash'
                          ? 'Tiền mặt'
                          : 'Chuyển khoản',
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('Chiết Khấu:'),
                  _buildInputField(
                    controller: TextEditingController(
                      text: AppFormatters.formatCurrencyNoSymbol(
                        order.discount,
                      ),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Tổng Thành Tiền:'),
                  Container(
                    height: 40,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: const Color(0xFF0E567C)),
                    ),
                    child: Text(
                      AppFormatters.formatCurrencyNoSymbol(order.totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildCartTable(order),
            const SizedBox(height: 20),
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
    bool readOnly = true,
  }) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFE5E7EB),
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

  Widget _buildCartTable(OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0E567C)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              border: Border(bottom: BorderSide(color: Color(0xFF0E567C))),
            ),
            child: Row(
              children: const [
                Expanded(
                  flex: 5,
                  child: Text(
                    'Mã hàng hóa',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'SL',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Thành Tiền',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          if (order.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Không có sản phẩm',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...order.items.map((item) {
              final name = item.product.name.isNotEmpty
                  ? item.product.name
                  : 'Tên hàng hóa';
              final code = item.product.code.isNotEmpty
                  ? item.product.code
                  : item.product.id;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            code,
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
                      child: Text(
                        item.quantity.toString(),
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        AppFormatters.formatCurrencyNoSymbol(item.total),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
