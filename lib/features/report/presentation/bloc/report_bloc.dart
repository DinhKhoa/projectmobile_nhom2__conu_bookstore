import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/domain/entities/report_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/domain/repositories/report_repository.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object> get props => [];
}

class GetRevenueReportRequested extends ReportEvent {
  final String start;
  final String end;

  const GetRevenueReportRequested(this.start, this.end);

  @override
  List<Object> get props => [start, end];
}

class GetProductReportRequested extends ReportEvent {
  final String start;
  final String end;
  final bool slowSelling;

  const GetProductReportRequested(this.start, this.end, this.slowSelling);

  @override
  List<Object> get props => [start, end, slowSelling];
}

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class RevenueReportLoaded extends ReportState {
  final RevenueSummaryEntity summary;
  final List<DailyRevenueEntity> daily;

  const RevenueReportLoaded(this.summary, this.daily);

  @override
  List<Object?> get props => [summary, daily];
}

class ProductReportLoaded extends ReportState {
  final List<ProductReportEntity> products;

  const ProductReportLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class ReportFailure extends ReportState {
  final String message;

  const ReportFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository repository;

  ReportBloc({required this.repository}) : super(ReportInitial()) {
    on<GetRevenueReportRequested>((event, emit) async {
      emit(ReportLoading());
      final result = await repository.getRevenueReport(event.start, event.end);
      result.fold(
        (failure) => emit(ReportFailure(failure.message)),
        (data) => emit(RevenueReportLoaded(data.$1, data.$2)),
      );
    });
    on<GetProductReportRequested>((event, emit) async {
      emit(ReportLoading());
      final result = await repository.getProductReport(
        event.start,
        event.end,
        event.slowSelling,
      );
      result.fold(
        (failure) => emit(ReportFailure(failure.message)),
        (products) => emit(ProductReportLoaded(products)),
      );
    });
  }
}
