import 'package:equatable/equatable.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/domain/entities/customer_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/domain/entities/order_entity.dart';

enum SalesStatus { initial, loading, success, failure }

class SalesState extends Equatable {
  final SalesStatus status;
  final List<OrderItemEntity> cartItems;
  final List<OrderEntity> orders;
  final CustomerEntity? selectedCustomer;
  final double discount;
  final String? errorMessage;

  const SalesState({
    this.status = SalesStatus.initial,
    this.cartItems = const [],
    this.orders = const [],
    this.selectedCustomer,
    this.discount = 0,
    this.errorMessage,
  });

  double get subTotal => cartItems.fold(0, (sum, item) => sum + item.total);

  double get totalRevenue => subTotal - discount;

  SalesState copyWith({
    SalesStatus? status,
    List<OrderItemEntity>? cartItems,
    List<OrderEntity>? orders,
    CustomerEntity? selectedCustomer,
    double? discount,
    String? errorMessage,
  }) {
    return SalesState(
      status: status ?? this.status,
      cartItems: cartItems ?? this.cartItems,
      orders: orders ?? this.orders,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      discount: discount ?? this.discount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    cartItems,
    orders,
    selectedCustomer,
    discount,
    errorMessage,
  ];
}
