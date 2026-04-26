const Order = require('../models/Order');
const OrderDetail = require('../models/OrderDetail');
const Product = require('../models/Product');

const parseDate = (str, isEnd = false) => {
  const [d, m, y] = str.split('/');
  const date = new Date(parseInt(y), parseInt(m) - 1, parseInt(d));
  if (isEnd) date.setHours(23, 59, 59, 999);
  else date.setHours(0, 0, 0, 0);
  return date;
};

const getRevenueReport = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    const start = parseDate(startDate);
    const end = parseDate(endDate, true);

    const duration = end.getTime() - start.getTime();
    const prevStart = new Date(start.getTime() - duration - 1);
    const prevEnd = new Date(start.getTime() - 1);

    const getSummary = async (s, e) => {
      const data = await Order.aggregate([
        { $match: { NgayBan: { $gte: s, $lte: e }, TrangThai: 'Hoàn thành' } },
        {
          $group: {
            _id: { $dateToString: { format: '%Y-%m-%d', date: '$NgayBan' } },
            orderCount: { $sum: 1 },
            tongThanhTien: { $sum: '$TongThanhTien' },
            chietKhau: { $sum: '$ChietKhau' },
          },
        },
      ]);
      const totals = data.reduce((acc, d) => ({
        orders: acc.orders + d.orderCount,
        revenue: acc.revenue + d.tongThanhTien,
      }), { orders: 0, revenue: 0 });
      return { daily: data, summary: totals };
    };

    const current = await getSummary(start, end);
    const previous = await getSummary(prevStart, prevEnd);

    const calcPercent = (curr, prev) => (prev <= 0 ? (curr > 0 ? 100 : 0) : parseFloat(((curr - prev) / prev * 100).toFixed(2)));

    res.json({
      success: true,
      data: {
        daily: current.daily,
        summary: {
          orders: { value: current.summary.orders, percent: calcPercent(current.summary.orders, previous.summary.orders) },
          netRevenue: { value: current.summary.revenue, percent: calcPercent(current.summary.revenue, previous.summary.revenue) },
          grossProfit: { value: current.summary.revenue * 0.4, percent: 0 } // Giả định 40% lợi nhuận nếu không tính chi tiết
        }
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getProductReport = async (req, res) => {
  try {
    const { startDate, endDate, type = 'best' } = req.query;
    const start = parseDate(startDate);
    const end = parseDate(endDate, true);
    const sortDir = type === 'best' ? -1 : 1;

    const data = await OrderDetail.aggregate([
      {
        $lookup: {
          from: 'orders',
          localField: 'MaHoaDonBan',
          foreignField: '_id',
          as: 'order',
        },
      },
      { $unwind: '$order' },
      { $match: { 'order.NgayBan': { $gte: start, $lte: end }, 'order.TrangThai': 'Hoàn thành' } },
      {
        $group: {
          _id: '$MaHH',
          soldQuantity: { $sum: '$SoLuongBan' },
          totalRevenue: { $sum: '$ThanhTien' },
        },
      },
      {
        $lookup: {
          from: 'products',
          localField: '_id',
          foreignField: '_id',
          as: 'product',
        },
      },
      { $unwind: '$product' },
      {
        $project: {
          TenHH: '$product.TenHH',
          MaHH: '$product.MaHH',
          soldQuantity: 1,
          totalRevenue: 1,
          LoiNhuan: { $multiply: ['$soldQuantity', '$product.LoiNhuan'] }
        },
      },
      { $sort: { soldQuantity: sortDir } },
      { $limit: 25 },
    ]);

    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { getRevenueReport, getProductReport };
