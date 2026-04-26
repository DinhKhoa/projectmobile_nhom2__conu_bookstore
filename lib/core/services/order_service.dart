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
    final queryParams = <String, String>{
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
    double chietKhau = 0,
    String paymentMethod = 'Tiền mặt',
    String? note,
  }) async {
    final body = <String, dynamic>{
      'items': items,
      'ChietKhau': chietKhau,
      'PhuongThucThanhToan': paymentMethod,
      ...?(customerId != null ? {'MaKH': customerId} : null),
      ...?(note != null ? {'note': note} : null),
    };

    final result = await ApiService.post('/orders', body);
    return result;
  }

  /// Lấy mã hóa đơn bán tiếp theo
  /// GET /api/orders/next-code
  static Future<String> getNextOrderCode() async {
    final result = await ApiService.get('/orders/next-code');
    if (result['success'] == true) {
      return result['data']?['nextCode'] ?? '';
    }
    throw Exception(result['message'] ?? 'Lỗi lấy mã hóa đơn');
  }
}
