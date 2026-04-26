import 'category.dart';

class Product {
  final String id;
  final String maHH;
  final String tenHH;
  final String maVach;
  final String donViTinh;
  final double loiNhuan;
  final double giaBan;
  final int soLuong;
  final int nguongCanhBao;
  final String trangThai;
  final dynamic maLoai; // Can be ID or Category object

  String get categoryName => (maLoai is Category) ? (maLoai as Category).tenLoai : 'N/A';
  String get maLoaiId => (maLoai is Category) ? (maLoai as Category).id : maLoai.toString();

  Product({
    required this.id,
    required this.maHH,
    required this.tenHH,
    required this.maVach,
    required this.donViTinh,
    required this.loiNhuan,
    required this.giaBan,
    required this.soLuong,
    required this.nguongCanhBao,
    required this.trangThai,
    required this.maLoai,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      maHH: json['MaHH'] ?? '',
      tenHH: json['TenHH'] ?? '',
      maVach: json['MaVach'] ?? '',
      donViTinh: json['DonViTinh'] ?? 'cuốn',
      loiNhuan: (json['LoiNhuan'] as num? ?? 0).toDouble(),
      giaBan: (json['GiaBan'] as num? ?? 0).toDouble(),
      soLuong: (json['SoLuong'] as num? ?? 0).toInt(),
      nguongCanhBao: (json['NguongCanhBao'] as num? ?? 10).toInt(),
      trangThai: json['TrangThai'] ?? 'active',
      maLoai: json['MaLoai'] is Map ? Category.fromJson(json['MaLoai']) : (json['MaLoai'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MaHH': maHH,
      'TenHH': tenHH,
      'MaVach': maVach,
      'DonViTinh': donViTinh,
      'LoiNhuan': loiNhuan,
      'GiaBan': giaBan,
      'SoLuong': soLuong,
      'NguongCanhBao': nguongCanhBao,
      'TrangThai': trangThai,
      'MaLoai': (maLoai is Category) ? (maLoai as Category).id : maLoai,
    };
  }
}
