import 'package:equatable/equatable.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/domain/entities/product_entity.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsRequested extends ProductEvent {}

class CreateProductRequested extends ProductEvent {
  final ProductEntity product;

  const CreateProductRequested(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProductRequested extends ProductEvent {
  final String id;
  final ProductEntity product;

  const UpdateProductRequested(this.id, this.product);

  @override
  List<Object?> get props => [id, product];
}

class DeleteProductRequested extends ProductEvent {
  final String id;

  const DeleteProductRequested(this.id);

  @override
  List<Object?> get props => [id];
}
