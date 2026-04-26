class Customer {
  final String id;
  final String maKH;
  final String tenKH;
  final String diaChi;
  final String sdt;

  Customer({
    required this.id,
    required this.maKH,
    required this.tenKH,
    required this.diaChi,
    required this.sdt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['_id'] ?? '',
      maKH: json['MaKH'] ?? '',
      tenKH: json['TenKH'] ?? 'Khách lẻ',
      diaChi: json['DiaChiKhachHang'] ?? '',
      sdt: json['SDTKhachHang'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MaKH': maKH,
      'TenKH': tenKH,
      'DiaChiKhachHang': diaChi,
      'SDTKhachHang': sdt,
    };
  }
}
