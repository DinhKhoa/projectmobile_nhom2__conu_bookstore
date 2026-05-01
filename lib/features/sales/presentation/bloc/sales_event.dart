import 'package:equatable/equatable.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/domain/entities/customer_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/domain/entities/product_entity.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();

  @override
  List<Object?> get props => [];
}

class AddProductToCart extends SalesEvent {
  final ProductEntity product;

  const AddProductToCart(this.product);

  @override
  List<Object?> get props => [product];
}

class RemoveProductFromCart extends SalesEvent {
  final String productId;

  const RemoveProductFromCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateProductQuantity extends SalesEvent {
  final String productId;
  final int quantity;

  const UpdateProductQuantity(this.productId, this.quantity);

  @override
  List<Object?> get props => [productId, quantity];
}

class SelectCustomer extends SalesEvent {
  final CustomerEntity? customer;

  const SelectCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

class UpdateDiscount extends SalesEvent {
  final double discount;

  const UpdateDiscount(this.discount);

  @override
  List<Object?> get props => [discount];
}

class LoadOrdersRequested extends SalesEvent {}

class SubmitOrderRequested extends SalesEvent {}
