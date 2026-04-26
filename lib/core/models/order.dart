import 'customer.dart';
import 'product.dart';

class OrderItem {
  final String id;
  final String maCTHoaDonBan;
  final int soLuongBan;
  final double thanhTien;
  final dynamic maHH; // ID or Product object

  OrderItem({
    required this.id,
    required this.maCTHoaDonBan,
    required this.soLuongBan,
    required this.thanhTien,
    required this.maHH,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id'] ?? '',
      maCTHoaDonBan: json['MaCTHoaDonBan'] ?? '',
      soLuongBan: (json['SoLuongBan'] as num? ?? 0).toInt(),
      thanhTien: (json['ThanhTien'] as num? ?? 0).toDouble(),
      maHH: json['MaHH'] is Map ? Product.fromJson(json['MaHH'] as Map<String, dynamic>) : (json['MaHH'] ?? ''),
    );
  }
}

class Order {
  final String id;
  final String maHoaDonBan;
  final DateTime ngayBan;
  final double chietKhau;
  final double tongThanhTien;
  final String trangThai;
  final String phuongThucThanhToan;
  final dynamic maKH; // ID or Customer object
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.maHoaDonBan,
    required this.ngayBan,
    required this.chietKhau,
    required this.tongThanhTien,
    required this.trangThai,
    required this.phuongThucThanhToan,
    required this.maKH,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      maHoaDonBan: json['MaHoaDonBan'] ?? '',
      ngayBan: DateTime.parse(json['NgayBan'] ?? DateTime.now().toIso8601String()),
      chietKhau: (json['ChietKhau'] as num? ?? 0).toDouble(),
      tongThanhTien: (json['TongThanhTien'] as num? ?? 0).toDouble(),
      trangThai: json['TrangThai'] ?? 'Hoàn thành',
      phuongThucThanhToan: json['PhuongThucThanhToan'] ?? 'Tiền mặt',
      maKH: json['MaKH'] is Map ? Customer.fromJson(json['MaKH'] as Map<String, dynamic>) : (json['MaKH'] ?? ''),
      items: (json['items'] as List? ?? []).map((i) => OrderItem.fromJson(i as Map<String, dynamic>)).toList(),
    );
  }
}
