import 'package:intl/intl.dart';

class RevenueSummary {
  final double netRevenue;
  final double grossProfit;
  final int totalOrders;
  final double netRevenueChange;
  final double grossProfitChange;
  final double totalOrdersChange;

  RevenueSummary({
    required this.netRevenue,
    required this.grossProfit,
    required this.totalOrders,
    required this.netRevenueChange,
    required this.grossProfitChange,
    required this.totalOrdersChange,
  });
}

class DailyRevenue {
  final DateTime date;
  final int orderCount;
  final double totalAmount;   // subTotal (tiền hàng)
  final double discount;       // chiết khấu
  final double returnAmount;   // tiền hàng trả lại
  final double tax;            // tiền thuế
  final double netRevenue;     // doanh thu thuần
  final double totalRevenue;   // tổng doanh thu
  final double grossProfit;    // lợi nhuận gộp

  DailyRevenue({
    required this.date,
    required this.orderCount,
    required this.totalAmount,
    required this.discount,
    this.returnAmount = 0,
    this.tax = 0,
    this.netRevenue = 0,
    this.totalRevenue = 0,
    this.grossProfit = 0,
  });

  String get formattedDate => DateFormat('dd/MM').format(date);
  String get fullFormattedDate => DateFormat('dd/MM/yyyy').format(date);
}

class ProductReportItem {
  final String productName;
  final String category;
  final int soldQuantity;
  final double totalRevenue;   // tiền hàng
  final double discount;        // chiết khấu
  final double returnAmount;    // tiền hàng trả lại
  final double netRevenue;      // doanh thu thuần
  final double totalRevenueWithTax; // tổng doanh thu
  final double grossProfit;     // lợi nhuận gộp

  ProductReportItem({
    required this.productName,
    required this.category,
    required this.soldQuantity,
    required this.totalRevenue,
    this.discount = 0,
    this.returnAmount = 0,
    this.netRevenue = 0,
    this.totalRevenueWithTax = 0,
    this.grossProfit = 0,
  });
}
