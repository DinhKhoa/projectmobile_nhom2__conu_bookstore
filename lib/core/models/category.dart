class Category {
  final String id;
  final String maLoai;
  final String tenLoai;
  final String trangThai;

  Category({
    required this.id,
    required this.maLoai,
    required this.tenLoai,
    required this.trangThai,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      maLoai: json['MaLoai'] ?? '',
      tenLoai: json['TenLoai'] ?? '',
      trangThai: json['TrangThai'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MaLoai': maLoai,
      'TenLoai': tenLoai,
      'TrangThai': trangThai,
    };
  }
}
