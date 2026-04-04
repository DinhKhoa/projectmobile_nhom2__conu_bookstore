import 'dart:math';
import 'report_models.dart';

class MockReportData {
  static final _random = Random();

  static List<DailyRevenue> generateDailyRevenue(DateTime start, DateTime end) {
    final List<DailyRevenue> data = [];
    final days = end.difference(start).inDays + 1;

    for (int i = 0; i < days; i++) {
      final date = start.add(Duration(days: i));
      final totalAmount = 500000 + _random.nextDouble() * 4500000;
      final double discount = _random.nextDouble() > 0.7 ? 50000 + _random.nextDouble() * 200000 : 0.0;
      final returnAmt = totalAmount * 0.05;
      final net = totalAmount - discount - returnAmt;
      final tax = net * 0.1;
      data.add(DailyRevenue(
        date: date,
        orderCount: 5 + _random.nextInt(45),
        totalAmount: totalAmount,
        discount: discount,
        returnAmount: returnAmt,
        tax: tax,
        netRevenue: net,
        totalRevenue: net + tax,
      ));
    }
    return data;
  }

  static RevenueSummary generateSummary(List<DailyRevenue> dailyData) {
    double totalNet = 0;
    int totalOrders = 0;
    for (var d in dailyData) {
      totalNet += d.netRevenue;
      totalOrders += d.orderCount;
    }
    return RevenueSummary(
      netRevenue: totalNet,
      grossProfit: totalNet * 0.85,
      totalOrders: totalOrders,
      netRevenueChange: 100.0,
      grossProfitChange: 100.0,
      totalOrdersChange: 100.0,
    );
  }

  static List<ProductReportItem> generateProductRanking({int count = 20, bool slowSelling = false}) {
    final products = [
      "Bút mực tím Deli", "Truyện Conan tập 1", "Vở ABC 4 ô ly-96tr",
      "Bút chì Thiên Long 2B", "Sách toán lớp 2-tập 1", "Sách toán lớp 3-tập 1",
      "Sách toán lớp 4-tập 1", "Bút mực xanh Deli", "Bút mực đen Deli",
      "Sổ tay ghi chú A5", "Tẩy Gôm Campus", "Thước kẻ 20cm",
      "Hộp bút sắt", "Màu sáp Colokit", "Giấy A4 Double A",
      "Kéo văn phòng", "Hồ dán nước", "Ghim bấm gỗ",
      "Bìa nút A4", "Bút dạ quang"
    ];
    final categories = ["Dụng cụ học tập", "Truyện tranh", "Vở viết", "Sách giáo khoa", "Quà tặng"];

    final List<ProductReportItem> data = [];
    for (int i = 0; i < count; i++) {
      final soldQuantity = slowSelling ? 1 + _random.nextInt(15) : 50 + _random.nextInt(200);
      final revenue = soldQuantity * (20000 + _random.nextInt(50000)).toDouble();
      final disc = revenue * 0.02;
      final ret = revenue * 0.01;
      final net = revenue - disc - ret;
      data.add(ProductReportItem(
        productName: products[i % products.length],
        category: categories[_random.nextInt(categories.length)],
        soldQuantity: soldQuantity,
        totalRevenue: revenue,
        discount: disc,
        returnAmount: ret,
        netRevenue: net,
        totalRevenueWithTax: net * 1.1,
      ));
    }

    data.sort((a, b) => slowSelling
        ? a.soldQuantity.compareTo(b.soldQuantity)
        : b.soldQuantity.compareTo(a.soldQuantity));
    return data;
  }
}
