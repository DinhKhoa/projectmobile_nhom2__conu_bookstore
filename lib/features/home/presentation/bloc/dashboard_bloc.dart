import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/domain/entities/report_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/domain/repositories/report_repository.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardDataRequested extends DashboardEvent {}

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final RevenueSummaryEntity summary;
  final List<DailyRevenueEntity> weeklyRevenue;
  final List<ProductReportEntity> topSellingProducts;

  const DashboardLoaded({
    required this.summary,
    required this.weeklyRevenue,
    required this.topSellingProducts,
  });

  @override
  List<Object?> get props => [summary, weeklyRevenue, topSellingProducts];
}

class DashboardFailure extends DashboardState {
  final String message;

  const DashboardFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ReportRepository reportRepository;

  DashboardBloc({required this.reportRepository}) : super(DashboardInitial()) {
    on<LoadDashboardDataRequested>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardDataRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final revenueResult = await reportRepository.getRevenueReport(
      "20/04/2026",
      "26/04/2026",
    );
    final productResult = await reportRepository.getProductReport(
      "20/04/2026",
      "26/04/2026",
      false,
    );
    revenueResult.fold((failure) => emit(DashboardFailure(failure.message)), (
      revenueData,
    ) {
      productResult.fold(
        (failure) => emit(DashboardFailure(failure.message)),
        (products) => emit(
          DashboardLoaded(
            summary: revenueData.$1,
            weeklyRevenue: revenueData.$2,
            topSellingProducts: products.take(5).toList(),
          ),
        ),
      );
    });
  }
}
