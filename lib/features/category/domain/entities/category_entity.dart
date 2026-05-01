import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final String? description;

  const CategoryEntity({
    required this.id,
    required this.code,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, code, name, description];
}
