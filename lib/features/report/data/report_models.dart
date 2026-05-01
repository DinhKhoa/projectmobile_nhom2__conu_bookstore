import 'package:projectmobile_nhom2__conu_bookstore/features/report/domain/entities/report_entity.dart';

class RevenueSummaryModel extends RevenueSummaryEntity {
  const RevenueSummaryModel({
    required super.netRevenue,
    required super.grossProfit,
    required super.totalOrders,
    required super.netRevenueChange,
    required super.grossProfitChange,
    required super.totalOrdersChange,
  });

  factory RevenueSummaryModel.fromJson(Map<String, dynamic> json) {
    return RevenueSummaryModel(
      netRevenue: (json['netRevenue'] ?? 0).toDouble(),
      grossProfit: (json['grossProfit'] ?? 0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      netRevenueChange: (json['netRevenueChange'] ?? 0).toDouble(),
      grossProfitChange: (json['grossProfitChange'] ?? 0).toDouble(),
      totalOrdersChange: (json['totalOrdersChange'] ?? 0).toDouble(),
    );
  }
}

class DailyRevenueModel extends DailyRevenueEntity {
  const DailyRevenueModel({
    required super.date,
    required super.orderCount,
    required super.totalAmount,
    super.netRevenue,
    super.totalRevenue,
    super.grossProfit,
  });

  factory DailyRevenueModel.fromJson(Map<String, dynamic> json) {
    return DailyRevenueModel(
      date: DateTime.parse(json['date']),
      orderCount: json['orderCount'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      netRevenue: (json['netRevenue'] ?? 0).toDouble(),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      grossProfit: (json['grossProfit'] ?? 0).toDouble(),
    );
  }
}

class ProductReportModel extends ProductReportEntity {
  const ProductReportModel({
    required super.productName,
    required super.category,
    required super.soldQuantity,
    required super.totalRevenue,
    super.netRevenue,
    super.grossProfit,
  });

  factory ProductReportModel.fromJson(Map<String, dynamic> json) {
    return ProductReportModel(
      productName: json['productName'] ?? '',
      category: json['category'] ?? '',
      soldQuantity: json['soldQuantity'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      netRevenue: (json['netRevenue'] ?? 0).toDouble(),
      grossProfit: (json['grossProfit'] ?? 0).toDouble(),
    );
  }
}
