import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String barcode;
  final String categoryId;
  final String? categoryName;
  final double price;
  final double profit;
  final int quantity;
  final String unit;
  final int minStock;
  final String status;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.barcode,
    required this.categoryId,
    this.categoryName,
    required this.price,
    required this.profit,
    required this.quantity,
    required this.unit,
    required this.minStock,
    required this.status,
  });

  ProductEntity copyWith({
    String? id,
    String? name,
    String? code,
    String? barcode,
    String? categoryId,
    String? categoryName,
    double? price,
    double? profit,
    int? quantity,
    String? unit,
    int? minStock,
    String? status,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      profit: profit ?? this.profit,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      minStock: minStock ?? this.minStock,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    barcode,
    categoryId,
    categoryName,
    price,
    profit,
    quantity,
    unit,
    minStock,
    status,
  ];
}
