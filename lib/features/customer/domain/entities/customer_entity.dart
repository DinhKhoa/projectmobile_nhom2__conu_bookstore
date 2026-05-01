import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final String phone;
  final String? email;
  final String? address;

  const CustomerEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.phone,
    this.email,
    this.address,
  });

  CustomerEntity copyWith({
    String? id,
    String? code,
    String? name,
    String? phone,
    String? email,
    String? address,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props => [id, code, name, phone, email, address];
}
