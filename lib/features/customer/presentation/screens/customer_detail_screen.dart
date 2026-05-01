import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/domain/entities/customer_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/presentation/bloc/customer_bloc.dart';

class CustomerDetailScreen extends StatefulWidget {
  final CustomerEntity? customer;
  final String? suggestedCode;
  final List<CustomerEntity>? allCustomers;

  const CustomerDetailScreen({
    super.key,
    this.customer,
    this.suggestedCode,
    this.allCustomers,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isChanged = false;
  late bool _isEdit;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.customer != null;
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController = TextEditingController(
      text: widget.customer?.phone ?? '',
    );
    _addressController = TextEditingController(
      text: widget.customer?.address ?? '',
    );
    _nameController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
    _addressController.addListener(_checkChanges);
    if (!_isEdit) {
      _isChanged = true;
    }
  }

  void _checkChanges() {
    if (!_isEdit) {
      final hasInput =
          _nameController.text.isNotEmpty ||
          _phoneController.text.isNotEmpty ||
          _addressController.text.isNotEmpty;
      if (hasInput != _isChanged) {
        setState(() => _isChanged = hasInput);
      }
      return;
    }
    final changed =
        _nameController.text != widget.customer!.name ||
        _phoneController.text != widget.customer!.phone ||
        _addressController.text != (widget.customer!.address ?? '');
    if (changed != _isChanged) {
      setState(() {
        _isChanged = changed;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
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
          'THÔNG TIN KHÁCH HÀNG',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const Text(
              'Thông Tin Khách Hàng:',
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
                  _buildLabel('Mã KH:'),
                  const SizedBox(height: 8),
                  _buildReadOnlyField(
                    _isEdit
                        ? widget.customer!.code
                        : (widget.suggestedCode ?? 'KH[Tự động]'),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Tên KH:'),
                  const SizedBox(height: 8),
                  _buildEditableField(_nameController, 'Nhập tên khách hàng'),
                  const SizedBox(height: 20),
                  _buildLabel('Địa chỉ:'),
                  const SizedBox(height: 8),
                  _buildEditableField(_addressController, 'Nhập địa chỉ'),
                  const SizedBox(height: 20),
                  _buildLabel('SĐT:'),
                  const SizedBox(height: 8),
                  _buildEditableField(
                    _phoneController,
                    'Nhập số điện thoại',
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                if (_isEdit) ...[
                  Expanded(
                    child: _buildButton(
                      onPressed: () => Navigator.pop(context),
                      label: 'Hủy',
                      icon: Icons.cancel_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                ],
                const SizedBox(width: 24),
                Expanded(
                  child: _buildButton(
                    onPressed: _isChanged
                        ? () {
                            final name = _nameController.text.trim();
                            final phone = _phoneController.text.trim();
                            final address = _addressController.text.trim();
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Tên khách hàng không được để trống',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (phone.length != 10 ||
                                !RegExp(r'^[0-9]+$').hasMatch(phone)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Số điện thoại phải bao gồm đúng 10 chữ số',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (widget.allCustomers != null) {
                              final duplicate = widget.allCustomers!.any((kh) {
                                if (_isEdit && kh.id == widget.customer!.id)
                                  return false;
                                return kh.phone == phone;
                              });
                              if (duplicate) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Số điện thoại này đã tồn tại trong hệ thống',
                                    ),
                                  ),
                                );
                                return;
                              }
                            }
                            if (_isEdit) {
                              context.read<CustomerBloc>().add(
                                UpdateCustomerEvent(
                                  widget.customer!.id,
                                  name,
                                  phone,
                                  address,
                                ),
                              );
                            } else {
                              context.read<CustomerBloc>().add(
                                AddCustomerEvent(name, phone, address),
                              );
                            }
                            Navigator.pop(context);
                          }
                        : null,
                    label: 'Lưu',
                    icon: Icons.file_download,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
    );
  }

  Widget _buildReadOnlyField(String value) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        style: const TextStyle(fontSize: 14.5, color: AppColors.textSecondary),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFE5E7EB),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
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
        style: const TextStyle(fontSize: 14.5),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14.5),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback? onPressed,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final bool disabled = onPressed == null;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: disabled ? Colors.grey[300] : color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: disabled ? 0 : 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
