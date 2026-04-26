import 'api_service.dart';
import '../../features/report/data/report_models.dart';

class ReportService {
  /// Báo cáo doanh thu theo thời gian
  static Future<({List<DailyRevenue> daily, RevenueSummary? summary})> getRevenueReport({
    required String startDate,
    required String endDate,
  }) async {
    final result = await ApiService.get('/report/revenue', queryParams: {
      'startDate': startDate,
      'endDate': endDate,
    });

    if (result['success'] != true) {
      throw Exception(result['message'] ?? 'Lỗi tải báo cáo doanh thu');
    }

    final data = result['data'] as Map<String, dynamic>?;
    if (data == null) {
      return (daily: <DailyRevenue>[], summary: null);
    }

    final dailyList = ((data['daily'] as List? ?? [])).map((item) {
      // Backend use %Y-%m-%d for _id
      final dateStr = item['_id'] as String? ?? '2026-01-01';
      final date = DateTime.parse(dateStr);

      return DailyRevenue(
        date: date,
        orderCount: (item['orderCount'] as num? ?? 0).toInt(),
        totalAmount: (item['tongThanhTien'] as num? ?? 0).toDouble(),
        discount: (item['chietKhau'] as num? ?? 0).toDouble(),
        returnAmount: 0,
        tax: 0,
        netRevenue: (item['tongThanhTien'] as num? ?? 0).toDouble(),
        totalRevenue: (item['tongThanhTien'] as num? ?? 0).toDouble(),
        grossProfit: (item['tongThanhTien'] as num? ?? 0) * 0.4, // Giả định 40% nếu không tính chi tiết
      );
    }).toList();

    RevenueSummary? summary;
    final s = data['summary'] as Map?;
    if (s != null) {
      final net = s['netRevenue'] as Map? ?? {};
      final orders = s['orders'] as Map? ?? {};
      final profit = s['grossProfit'] as Map? ?? {};

      summary = RevenueSummary(
        netRevenue: (net['value'] as num? ?? 0).toDouble(),
        grossProfit: (profit['value'] as num? ?? 0).toDouble(),
        totalOrders: (orders['value'] as num? ?? 0).toInt(),
        netRevenueChange: (net['percent'] as num? ?? 0).toDouble(),
        grossProfitChange: (profit['percent'] as num? ?? 0).toDouble(),
        totalOrdersChange: (orders['percent'] as num? ?? 0).toDouble(),
      );
    }

    return (daily: dailyList, summary: summary);
  }

  /// Báo cáo hàng hóa bán chạy / bán chậm
  static Future<List<ProductReportItem>> getProductReport({
    required String startDate,
    required String endDate,
    required bool slowSelling,
  }) async {
    final result = await ApiService.get('/report/products', queryParams: {
      'startDate': startDate,
      'endDate': endDate,
      'type': slowSelling ? 'slow' : 'best',
    });

    if (result['success'] != true) {
      throw Exception(result['message'] ?? 'Lỗi tải báo cáo hàng hóa');
    }

    final dataList = result['data'] as List? ?? [];
    return dataList.map((item) {
      return ProductReportItem(
        productName: item['TenHH'] as String? ?? 'N/A',
        category: 'N/A',
        soldQuantity: (item['soldQuantity'] as num? ?? 0).toInt(),
        totalRevenue: (item['totalRevenue'] as num? ?? 0).toDouble(),
        discount: 0,
        returnAmount: 0,
        netRevenue: (item['totalRevenue'] as num? ?? 0).toDouble(),
        totalRevenueWithTax: (item['totalRevenue'] as num? ?? 0).toDouble(),
        grossProfit: (item['LoiNhuan'] as num? ?? 0).toDouble(),
      );
    }).toList();
  }
}
