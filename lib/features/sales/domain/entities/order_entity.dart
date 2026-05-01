import 'package:equatable/equatable.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/domain/entities/product_entity.dart';

class OrderItemEntity extends Equatable {
  final ProductEntity product;
  final int quantity;
  final double discount;

  const OrderItemEntity({
    required this.product,
    this.quantity = 1,
    this.discount = 0,
  });

  double get total => (product.price * quantity) - discount;

  OrderItemEntity copyWith({int? quantity, double? discount}) {
    return OrderItemEntity(
      product: product,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }

  @override
  List<Object?> get props => [product, quantity, discount];
}

class OrderEntity extends Equatable {
  final String? id;
  final String? customerId;
  final String? customerCode;
  final String customerName;
  final String? customerPhone;
  final String? customerAddress;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final double discount;
  final String paymentMethod;
  final DateTime? createdAt;

  const OrderEntity({
    this.id,
    this.customerId,
    this.customerCode,
    required this.customerName,
    this.customerPhone,
    this.customerAddress,
    required this.items,
    required this.totalAmount,
    required this.discount,
    required this.paymentMethod,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    customerId,
    customerCode,
    customerName,
    customerPhone,
    customerAddress,
    items,
    totalAmount,
    discount,
    paymentMethod,
    createdAt,
  ];
}
