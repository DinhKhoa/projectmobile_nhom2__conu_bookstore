import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/domain/entities/category_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/domain/repositories/category_repository.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadCategoriesEvent extends CategoryEvent {}

class AddCategoryEvent extends CategoryEvent {
  final String name;

  const AddCategoryEvent(this.name);

  @override
  List<Object> get props => [name];
}

class UpdateCategoryEvent extends CategoryEvent {
  final String id;
  final String name;

  const UpdateCategoryEvent(this.id, this.name);

  @override
  List<Object> get props => [id, name];
}

class DeleteCategoryEvent extends CategoryEvent {
  final String id;

  const DeleteCategoryEvent(this.id);

  @override
  List<Object> get props => [id];
}

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryEntity> categories;

  const CategoryLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class CategoryActionSuccess extends CategoryState {
  final String message;

  const CategoryActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  CategoryBloc({required this.repository}) : super(CategoryInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    final result = await repository.getAllCategories();
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final newCategory = CategoryEntity(id: '', code: '', name: event.name);
    final result = await repository.createCategory(newCategory);
    result.fold((failure) => emit(CategoryError(failure.message)), (success) {
      emit(const CategoryActionSuccess('Thêm loại hàng thành công!'));
      add(LoadCategoriesEvent());
    });
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final updatedCategory = CategoryEntity(
      id: event.id,
      code: '',
      name: event.name,
    );
    final result = await repository.updateCategory(event.id, updatedCategory);
    result.fold((failure) => emit(CategoryError(failure.message)), (success) {
      emit(const CategoryActionSuccess('Cập nhật thành công!'));
      add(LoadCategoriesEvent());
    });
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await repository.deleteCategory(event.id);
    result.fold((failure) => emit(CategoryError(failure.message)), (success) {
      emit(const CategoryActionSuccess('Xóa thành công!'));
      add(LoadCategoriesEvent());
    });
  }
}
