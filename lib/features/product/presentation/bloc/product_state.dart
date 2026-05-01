import 'package:equatable/equatable.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/domain/entities/product_entity.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<ProductEntity> products;

  const ProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductActionSuccess extends ProductState {
  final String message;

  const ProductActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductFailure extends ProductState {
  final String message;

  const ProductFailure(this.message);

  @override
  List<Object?> get props => [message];
}
