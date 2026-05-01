import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/domain/entities/order_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/domain/repositories/order_repository.dart';

import 'sales_event.dart';
import 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final OrderRepository repository;

  SalesBloc({required this.repository}) : super(const SalesState()) {
    on<AddProductToCart>(_onAddProductToCart);
    on<RemoveProductFromCart>(_onRemoveProductFromCart);
    on<UpdateProductQuantity>(_onUpdateProductQuantity);
    on<SelectCustomer>(_onSelectCustomer);
    on<UpdateDiscount>(_onUpdateDiscount);
    on<LoadOrdersRequested>(_onLoadOrdersRequested);
    on<SubmitOrderRequested>(_onSubmitOrderRequested);
  }

  Future<void> _onLoadOrdersRequested(
    LoadOrdersRequested event,
    Emitter<SalesState> emit,
  ) async {
    emit(state.copyWith(status: SalesStatus.loading));
    final result = await repository.getAllOrders();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SalesStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (orders) =>
          emit(state.copyWith(status: SalesStatus.success, orders: orders)),
    );
  }

  void _onAddProductToCart(AddProductToCart event, Emitter<SalesState> emit) {
    final updatedCart = List<OrderItemEntity>.from(state.cartItems);
    final index = updatedCart.indexWhere(
      (i) => i.product.id == event.product.id,
    );
    if (index >= 0) {
      updatedCart[index] = updatedCart[index].copyWith(
        quantity: updatedCart[index].quantity + 1,
      );
    } else {
      updatedCart.add(OrderItemEntity(product: event.product));
    }
    emit(state.copyWith(cartItems: updatedCart));
  }

  void _onRemoveProductFromCart(
    RemoveProductFromCart event,
    Emitter<SalesState> emit,
  ) {
    final updatedCart = state.cartItems
        .where((i) => i.product.id != event.productId)
        .toList();
    emit(state.copyWith(cartItems: updatedCart));
  }

  void _onUpdateProductQuantity(
    UpdateProductQuantity event,
    Emitter<SalesState> emit,
  ) {
    final updatedCart = List<OrderItemEntity>.from(state.cartItems);
    final index = updatedCart.indexWhere(
      (i) => i.product.id == event.productId,
    );
    if (index >= 0) {
      if (event.quantity <= 0) {
        updatedCart.removeAt(index);
      } else {
        updatedCart[index] = updatedCart[index].copyWith(
          quantity: event.quantity,
        );
      }
      emit(state.copyWith(cartItems: updatedCart));
    }
  }

  void _onSelectCustomer(SelectCustomer event, Emitter<SalesState> emit) {
    emit(state.copyWith(selectedCustomer: event.customer));
  }

  void _onUpdateDiscount(UpdateDiscount event, Emitter<SalesState> emit) {
    emit(state.copyWith(discount: event.discount));
  }

  Future<void> _onSubmitOrderRequested(
    SubmitOrderRequested event,
    Emitter<SalesState> emit,
  ) async {
    if (state.cartItems.isEmpty) return;
    emit(state.copyWith(status: SalesStatus.loading));
    final order = OrderEntity(
      customerId: state.selectedCustomer?.id,
      customerName: state.selectedCustomer?.name ?? 'Khách lẻ',
      items: state.cartItems,
      totalAmount: state.totalRevenue,
      discount: state.discount,
      paymentMethod: 'cash',
    );
    final result = await repository.createOrder(order);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SalesStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (order) => emit(state.copyWith(status: SalesStatus.success)),
    );
  }
}
