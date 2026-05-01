import 'package:projectmobile_nhom2__conu_bookstore/features/product/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.code,
    required super.barcode,
    required super.categoryId,
    super.categoryName,
    required super.price,
    required super.profit,
    required super.quantity,
    required super.unit,
    required super.minStock,
    required super.status,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final maLoai = json['MaLoai'];
    String catId = '';
    String? catName;
    if (maLoai is Map) {
      catId = maLoai['_id']?.toString() ?? '';
      catName = maLoai['TenLoai']?.toString();
    } else {
      catId = maLoai?.toString() ?? '';
    }
    return ProductModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['TenHH'] ?? '',
      code: json['MaHH'] ?? '',
      barcode: json['MaVach'] ?? '',
      categoryId: catId,
      categoryName: catName,
      price: (json['GiaBan'] ?? 0).toDouble(),
      profit: (json['LoiNhuan'] ?? 0).toDouble(),
      quantity: json['SoLuong'] ?? 0,
      unit: json['DonViTinh'] ?? '',
      minStock: json['NguongCanhBao'] ?? 0,
      status: json['TrangThai'] ?? '',
    );
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      barcode: entity.barcode,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      price: entity.price,
      profit: entity.profit,
      quantity: entity.quantity,
      unit: entity.unit,
      minStock: entity.minStock,
      status: entity.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TenHH': name,
      'MaHH': code,
      'MaVach': barcode,
      'MaLoai': categoryId,
      'GiaBan': price,
      'LoiNhuan': profit,
      'SoLuong': quantity,
      'DonViTinh': unit,
      'NguongCanhBao': minStock,
      'TrangThai': status,
    };
  }
}
