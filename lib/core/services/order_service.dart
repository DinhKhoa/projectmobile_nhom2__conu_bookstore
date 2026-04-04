import 'api_service.dart';
import '../models/order.dart';

class OrderService {
  /// Lấy danh sách đơn hàng (Bán hàng)
  /// GET /api/orders
  static Future<List<Order>> getOrders({
    int page = 1,
    int limit = 100,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) queryParams['status'] = status;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final result = await ApiService.get('/orders', queryParams: queryParams);
    if (result['success'] != true) {
      throw Exception(result['message'] ?? 'Lỗi tải danh sách đơn hàng');
    }

    final List ordersRaw = result['data'] as List? ?? [];
    return ordersRaw.map((o) => Order.fromJson(o)).toList();
  }

  /// Tạo đơn hàng mới
  /// POST /api/orders
  static Future<Map<String, dynamic>> createOrder({
    String? customerId,
    String? customerName,
    required List<Map<String, dynamic>> items,
    double ChietKhau = 0,
    String paymentMethod = 'Tiền mặt',
    String? note,
  }) async {
    final body = {
      if (customerId != null) 'MaKH': customerId,
      'items': items,
      'ChietKhau': ChietKhau,
      'PhuongThucThanhToan': paymentMethod,
      if (note != null) 'note': note,
    };

    final result = await ApiService.post('/orders', body);
    return result;
  }
}
