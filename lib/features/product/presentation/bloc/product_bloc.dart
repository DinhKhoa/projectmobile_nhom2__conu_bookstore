import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/usecases/usecase.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/domain/repositories/product_repository.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/domain/usecases/get_all_products_usecase.dart';

import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetAllProductsUseCase getAllProductsUseCase;
  final ProductRepository repository;

  ProductBloc({required this.getAllProductsUseCase, required this.repository})
    : super(ProductInitial()) {
    on<LoadProductsRequested>(_onLoadProductsRequested);
    on<CreateProductRequested>(_onCreateProductRequested);
    on<UpdateProductRequested>(_onUpdateProductRequested);
    on<DeleteProductRequested>(_onDeleteProductRequested);
  }

  Future<void> _onLoadProductsRequested(
    LoadProductsRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final result = await getAllProductsUseCase(NoParams());
    result.fold(
      (failure) => emit(ProductFailure(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onCreateProductRequested(
    CreateProductRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final result = await repository.createProduct(event.product);
    await result.fold(
      (failure) async => emit(ProductFailure(failure.message)),
      (product) async {
        emit(const ProductActionSuccess('Thêm hàng hóa thành công!'));
        final refreshResult = await getAllProductsUseCase(NoParams());
        refreshResult.fold(
          (failure) => null,
          (products) => emit(ProductsLoaded(products)),
        );
      },
    );
  }

  Future<void> _onUpdateProductRequested(
    UpdateProductRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final result = await repository.updateProduct(event.id, event.product);
    await result.fold(
      (failure) async => emit(ProductFailure(failure.message)),
      (product) async {
        emit(const ProductActionSuccess('Cập nhật thành công!'));
        final refreshResult = await getAllProductsUseCase(NoParams());
        refreshResult.fold(
          (failure) => null,
          (products) => emit(ProductsLoaded(products)),
        );
      },
    );
  }

  Future<void> _onDeleteProductRequested(
    DeleteProductRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final result = await repository.deleteProduct(event.id);
    await result.fold(
      (failure) async => emit(ProductFailure(failure.message)),
      (_) async {
        emit(const ProductActionSuccess('Xóa thành công!'));
        final refreshResult = await getAllProductsUseCase(NoParams());
        refreshResult.fold(
          (failure) => null,
          (products) => emit(ProductsLoaded(products)),
        );
      },
    );
  }
}
