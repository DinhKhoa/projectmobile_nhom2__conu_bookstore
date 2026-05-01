import 'package:projectmobile_nhom2__conu_bookstore/features/product/data/models/product_model.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    super.id,
    super.customerId,
    super.customerCode,
    required super.customerName,
    super.customerPhone,
    super.customerAddress,
    required super.items,
    required super.totalAmount,
    required super.discount,
    required super.paymentMethod,
    super.createdAt,
  }) : super();

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String? phone;
    String name = 'Khách lẻ';
    String? customerCode;
    String? customerAddress;
    final kh = json['khachhang'];
    if (kh is List && kh.isNotEmpty) {
      final firstKh = kh[0];
      if (firstKh is Map) {
        phone = firstKh['SDTKhachHang']?.toString();
        name = firstKh['TenKH']?.toString() ?? 'Khách lẻ';
        customerCode = firstKh['MaKH']?.toString();
        customerAddress = firstKh['DiaChiKhachHang']?.toString();
      }
    } else {
      final makh = json['MaKH'];
      if (makh is Map) {
        phone = makh['SDTKhachHang']?.toString();
        name = makh['TenKH']?.toString() ?? 'Khách lẻ';
        customerCode = makh['MaKH']?.toString();
        customerAddress = makh['DiaChiKhachHang']?.toString();
      } else {
        name = json['customerName']?.toString() ?? 'Khách lẻ';
        customerCode = json['customerCode']?.toString();
        customerAddress = json['customerAddress']?.toString();
      }
    }
    final List<OrderItemEntity> items = [];
    final rawItems = json['items'];
    if (rawItems is List) {
      for (var i in rawItems) {
        if (i is Map) {
          final prodData = i['MaHH'];
          String id = '';
          String name = '';
          String code = '';
          double price = 0;
          if (prodData is Map) {
            id =
                prodData['id']?.toString() ?? prodData['_id']?.toString() ?? '';
            name = prodData['TenHH']?.toString() ?? '';
            code = prodData['MaHH']?.toString() ?? '';
            price = (prodData['GiaBan'] ?? 0).toDouble();
          } else {
            id = prodData?.toString() ?? '';
            name = (i['TenHH'] ?? i['TenSP'] ?? i['productName'] ?? '')
                .toString();
            code = (i['MaHH_code'] ?? i['MaSP'] ?? i['productCode'] ?? id)
                .toString();
            price = (i['DonGia'] ?? i['GiaBan'] ?? i['Gia'] ?? i['price'] ?? 0)
                .toDouble();
          }
          final product = ProductModel(
            id: id,
            name: name,
            code: code,
            barcode: '',
            categoryId: '',
            price: price,
            profit: 0,
            quantity: 0,
            unit: '',
            minStock: 0,
            status: '',
          );
          items.add(
            OrderItemEntity(
              product: product,
              quantity: i['SoLuongBan'] is num
                  ? (i['SoLuongBan'] as num).toInt()
                  : 1,
              discount: i['discount'] is num
                  ? (i['discount'] as num).toDouble()
                  : 0.0,
            ),
          );
        }
      }
    }
    return OrderModel(
      id:
          json['MaHoaDonBan']?.toString() ??
          json['id']?.toString() ??
          json['_id']?.toString() ??
          '',
      customerId:
          json['customerId']?.toString() ??
          (json['MaKH'] is Map
              ? json['MaKH']['_id']?.toString()
              : json['MaKH']?.toString()),
      customerCode: customerCode,
      customerName: name,
      customerPhone: phone,
      customerAddress: customerAddress,
      items: items,
      totalAmount: (json['TongThanhTien'] ?? json['totalAmount'] ?? 0)
          .toDouble(),
      discount: (json['ChietKhau'] ?? json['discount'] ?? 0).toDouble(),
      paymentMethod:
          json['paymentMethod'] ?? json['PhuongThucThanhToan'] ?? 'cash',
      createdAt: json['NgayBan'] != null
          ? DateTime.parse(json['NgayBan'])
          : (json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerCode': customerCode,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'items': items
          .map(
            (i) => {
              'MaHH': i.product.id,
              'SoLuongBan': i.quantity,
              'discount': i.discount,
            },
          )
          .toList(),
      'ChietKhau': discount,
      'paymentMethod': paymentMethod,
    };
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      customerId: entity.customerId,
      customerName: entity.customerName,
      items: entity.items,
      totalAmount: entity.totalAmount,
      discount: entity.discount,
      paymentMethod: entity.paymentMethod,
      createdAt: entity.createdAt,
    );
  }
}
