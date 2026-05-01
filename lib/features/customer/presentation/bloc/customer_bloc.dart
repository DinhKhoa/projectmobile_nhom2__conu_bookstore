import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/domain/entities/customer_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/domain/repositories/customer_repository.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object> get props => [];
}

class LoadCustomersEvent extends CustomerEvent {}

class AddCustomerEvent extends CustomerEvent {
  final String name;
  final String phone;
  final String address;

  const AddCustomerEvent(this.name, this.phone, this.address);

  @override
  List<Object> get props => [name, phone, address];
}

class UpdateCustomerEvent extends CustomerEvent {
  final String id;
  final String name;
  final String phone;
  final String address;

  const UpdateCustomerEvent(this.id, this.name, this.phone, this.address);

  @override
  List<Object> get props => [id, name, phone, address];
}

class DeleteCustomerEvent extends CustomerEvent {
  final String id;

  const DeleteCustomerEvent(this.id);

  @override
  List<Object> get props => [id];
}

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerEntity> customers;

  const CustomerLoaded(this.customers);

  @override
  List<Object?> get props => [customers];
}

class CustomerActionSuccess extends CustomerState {
  final String message;

  const CustomerActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository repository;

  CustomerBloc({required this.repository}) : super(CustomerInitial()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
    on<AddCustomerEvent>(_onAddCustomer);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
  }

  Future<void> _onLoadCustomers(
    LoadCustomersEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await repository.getAllCustomers();
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customers) => emit(CustomerLoaded(customers)),
    );
  }

  Future<void> _onAddCustomer(
    AddCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final newCustomer = CustomerEntity(
      id: '',
      code: '',
      name: event.name,
      phone: event.phone,
      address: event.address,
    );
    final result = await repository.createCustomer(newCustomer);
    await result.fold((failure) async => emit(CustomerError(failure.message)), (
      success,
    ) async {
      emit(const CustomerActionSuccess('Thêm khách hàng thành công!'));
      final refreshResult = await repository.getAllCustomers();
      refreshResult.fold(
        (failure) => null,
        (customers) => emit(CustomerLoaded(customers)),
      );
    });
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final updatedCustomer = CustomerEntity(
      id: event.id,
      code: '',
      name: event.name,
      phone: event.phone,
      address: event.address,
    );
    final result = await repository.updateCustomer(
      event.id,
      updatedCustomer: updatedCustomer,
    );
    await result.fold((failure) async => emit(CustomerError(failure.message)), (
      success,
    ) async {
      emit(const CustomerActionSuccess('Cập nhật thành công!'));
      final refreshResult = await repository.getAllCustomers();
      refreshResult.fold(
        (failure) => null,
        (customers) => emit(CustomerLoaded(customers)),
      );
    });
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await repository.deleteCustomer(event.id);
    await result.fold((failure) async => emit(CustomerError(failure.message)), (
      success,
    ) async {
      emit(const CustomerActionSuccess('Xóa thành công!'));
      final refreshResult = await repository.getAllCustomers();
      refreshResult.fold(
        (failure) => null,
        (customers) => emit(CustomerLoaded(customers)),
      );
    });
  }
}
