import 'package:projectmobile_nhom2__conu_bookstore/features/customer/domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.code,
    required super.name,
    required super.phone,
    super.address,
  }) : super(email: null);

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      code: json['MaKH'] ?? '',
      name: json['TenKH'] ?? '',
      phone: json['SDTKhachHang'] ?? json['SDT'] ?? '',
      address: json['DiaChiKhachHang'] ?? json['DiaChi'],
    );
  }

  factory CustomerModel.fromEntity(CustomerEntity entity) {
    return CustomerModel(
      id: entity.id,
      code: entity.code,
      name: entity.name,
      phone: entity.phone,
      address: entity.address,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MaKH': code,
      'TenKH': name,
      'SDTKhachHang': phone,
      'DiaChiKhachHang': address,
    };
  }
}
