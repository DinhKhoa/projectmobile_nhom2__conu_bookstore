import 'package:projectmobile_nhom2__conu_bookstore/features/category/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.code,
    required super.name,
    super.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      code: json['MaLoai'] ?? '',
      name: json['TenLoai'] ?? '',
      description: json['MoTa'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'TenLoai': name};
    if (code.isNotEmpty) {
      data['MaLoai'] = code;
    }
    return data;
  }
}
