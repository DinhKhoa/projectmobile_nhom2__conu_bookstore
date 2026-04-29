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

// @desc    Lấy báo cáo doanh thu và tăng trưởng
// @route   GET /api/report/revenue?start=...&end=...
// @access  Private
const getRevenueReport = async (req, res) => {
  try {
    const { start: startDateStr, end: endDateStr } = req.query;
    const start = parseDate(startDateStr);
    const end = parseDate(endDateStr, true);
    const duration = end.getTime() - start.getTime();
    const prevStart = new Date(start.getTime() - duration - 1);
    const prevEnd = new Date(start.getTime() - 1);
    const getSummary = async (s, e) => {
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
        { $match: { 'order.NgayBan': { $gte: s, $lte: e } } },
        {
          $lookup: {
            from: 'products',
            localField: 'MaHH',
            foreignField: '_id',
            as: 'product',
          },
        },
        { $unwind: '$product' },
        {
          $addFields: {
            itemProfit: {
              $multiply: [
                '$SoLuongBan',
                '$product.GiaBan',
                { $divide: ['$product.LoiNhuan', 100] }
              ]
            }
          }
        },
        {
          $group: {
            _id: { $dateToString: { format: '%Y-%m-%d', date: '$order.NgayBan' } },
            orderIds: { $addToSet: '$MaHoaDonBan' },
            totalAmount: { $sum: '$ThanhTien' },
            totalProfit: { $sum: '$itemProfit' },
          },
        },
        {
          $project: {
            _id: 0,
            date: '$_id',
            orderCount: { $size: '$orderIds' },
            totalAmount: 1,
            netRevenue: '$totalAmount',
            totalRevenue: '$totalAmount',
            grossProfit: '$totalProfit',
          }
        },
        { $sort: { date: 1 } }
      ]);
      const totals = data.reduce((acc, d) => ({
        orders: acc.orders + d.orderCount,
        revenue: acc.revenue + d.totalAmount,
        profit: acc.profit + d.grossProfit,
      }), { orders: 0, revenue: 0, profit: 0 });
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
          totalOrders: current.summary.orders,
          totalOrdersChange: calcPercent(current.summary.orders, previous.summary.orders),
          netRevenue: current.summary.revenue,
          netRevenueChange: calcPercent(current.summary.revenue, previous.summary.revenue),
          grossProfit: current.summary.profit,
          grossProfitChange: calcPercent(current.summary.profit, previous.summary.profit)
        }
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
// @desc    Lấy báo cáo sản phẩm bán chạy/bán chậm
// @route   GET /api/report/products?start=...&end=...&slowSelling=...
// @access  Private
const getProductReport = async (req, res) => {
  try {
    const { start: startDateStr, end: endDateStr, slowSelling } = req.query;
    const start = parseDate(startDateStr);
    const end = parseDate(endDateStr, true);
    const sortDir = slowSelling === 'true' ? 1 : -1;
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
      { $match: { 'order.NgayBan': { $gte: start, $lte: end } } },
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
        $lookup: {
          from: 'categories',
          localField: 'product.MaLoai',
          foreignField: '_id',
          as: 'categoryInfo',
        },
      },
      {
        $project: {
          _id: 0,
          productName: '$product.TenHH',
          category: { $ifNull: [{ $arrayElemAt: ['$categoryInfo.TenLoai', 0] }, '---'] },
          soldQuantity: 1,
          totalRevenue: 1,
          netRevenue: '$totalRevenue',
          grossProfit: { 
            $multiply: [
              '$soldQuantity', 
              '$product.GiaBan', 
              { $divide: ['$product.LoiNhuan', 100] }
            ] 
          }
        },
      },
      {
        $match: slowSelling === 'true' 
          ? { soldQuantity: { $lte: 20 } } 
          : { soldQuantity: { $gt: 20 } } 
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