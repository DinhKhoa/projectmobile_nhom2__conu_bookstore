import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class RevenueSummaryEntity extends Equatable {
  final double netRevenue;
  final double grossProfit;
  final int totalOrders;
  final double netRevenueChange;
  final double grossProfitChange;
  final double totalOrdersChange;

  const RevenueSummaryEntity({
    required this.netRevenue,
    required this.grossProfit,
    required this.totalOrders,
    required this.netRevenueChange,
    required this.grossProfitChange,
    required this.totalOrdersChange,
  });

  @override
  List<Object?> get props => [
    netRevenue,
    grossProfit,
    totalOrders,
    netRevenueChange,
    grossProfitChange,
    totalOrdersChange,
  ];
}

class DailyRevenueEntity extends Equatable {
  final DateTime date;
  final int orderCount;
  final double totalAmount;
  final double netRevenue;
  final double totalRevenue;
  final double grossProfit;

  const DailyRevenueEntity({
    required this.date,
    required this.orderCount,
    required this.totalAmount,
    this.netRevenue = 0,
    this.totalRevenue = 0,
    this.grossProfit = 0,
  });

  @override
  List<Object?> get props => [
    date,
    orderCount,
    totalAmount,
    netRevenue,
    totalRevenue,
    grossProfit,
  ];

  String get formattedDate => DateFormat('dd/MM').format(date);

  String get fullFormattedDate => DateFormat('dd/MM/yyyy').format(date);
}

class ProductReportEntity extends Equatable {
  final String productName;
  final String category;
  final int soldQuantity;
  final double totalRevenue;
  final double netRevenue;
  final double grossProfit;

  const ProductReportEntity({
    required this.productName,
    required this.category,
    required this.soldQuantity,
    required this.totalRevenue,
    this.netRevenue = 0,
    this.grossProfit = 0,
  });

  @override
  List<Object?> get props => [
    productName,
    category,
    soldQuantity,
    totalRevenue,
    netRevenue,
    grossProfit,
  ];
}
