import 'package:dio/dio.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/utils/error_handler.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/data/report_models.dart';

abstract class ReportRemoteDataSource {
  Future<(RevenueSummaryModel, List<DailyRevenueModel>)> getRevenueReport(
    String start,
    String end,
  );

  Future<List<ProductReportModel>> getProductReport(
    String start,
    String end,
    bool slowSelling,
  );
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final Dio dio;

  ReportRemoteDataSourceImpl({required this.dio});

  @override
  Future<(RevenueSummaryModel, List<DailyRevenueModel>)> getRevenueReport(
    String start,
    String end,
  ) async {
    try {
      final response = await dio.get(
        '/report/revenue',
        queryParameters: {'start': start, 'end': end},
      );
      if (response.statusCode == 200) {
        final summary = RevenueSummaryModel.fromJson(
          response.data['data']['summary'],
        );
        final List dailyData = response.data['data']['daily'] ?? [];
        final daily = dailyData
            .map((json) => DailyRevenueModel.fromJson(json))
            .toList();
        return (summary, daily);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  @override
  Future<List<ProductReportModel>> getProductReport(
    String start,
    String end,
    bool slowSelling,
  ) async {
    try {
      final response = await dio.get(
        '/report/products',
        queryParameters: {
          'start': start,
          'end': end,
          'slowSelling': slowSelling.toString(),
        },
      );
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => ProductReportModel.fromJson(json)).toList();
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }
}
