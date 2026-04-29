const Order = require('../models/Order');
const OrderDetail = require('../models/OrderDetail');
const Product = require('../models/Product');

// @desc    Tạo hóa đơn bán hàng mới
// @route   POST /api/orders
// @access  Private
const createOrder = async (req, res) => {
  try {
    const { MaKH, customerId, customerName, customerCode, items, ChietKhau = 0, PhuongThucThanhToan } = req.body;
    if (!items || items.length === 0) {
      return res.status(400).json({ success: false, message: 'Đơn hàng phải có ít nhất 1 sản phẩm' });
    }
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const hour = String(now.getHours()).padStart(2, '0');
    const minute = String(now.getMinutes()).padStart(2, '0');
    const second = String(now.getSeconds()).padStart(2, '0');
    const MaHoaDonBan = `HDB${year}${month}${day}${hour}${minute}${second}`;
    const order = new Order({
      MaHoaDonBan,
      NgayBan: now,
      ChietKhau,
      TongThanhTien: 0, 
      PhuongThucThanhToan: PhuongThucThanhToan || 'Tiền mặt',
      MaKH: MaKH || customerId || null,
      customerName: customerName || 'Khách lẻ',
      customerCode: customerCode || null,
    });
    let tongThanhTien = 0;
    const details = [];
    for (const item of items) {
      const prod = await Product.findById(item.MaHH);
      if (!prod) continue;
      const thanhTien = item.SoLuongBan * prod.GiaBan;
      tongThanhTien += thanhTien;
      details.push({
        MaCTHoaDonBan: `CT${MaHoaDonBan}${prod.MaHH}`,
        SoLuongBan: item.SoLuongBan,
        ThanhTien: thanhTien,
        MaHoaDonBan: order._id,
        MaHH: prod._id,
      });
      prod.SoLuong -= item.SoLuongBan;
      await prod.save();
    }
    order.TongThanhTien = tongThanhTien - ChietKhau;
    await order.save();
    await OrderDetail.insertMany(details);
    res.status(201).json({ success: true, data: order });
  } catch (error) {
    console.error('ERROR IN createOrder:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};
// @desc    Lấy danh sách tất cả hóa đơn
// @route   GET /api/orders
// @access  Private
const getOrders = async (req, res) => {
  try {
    const orders = await Order.aggregate([
      {
        $lookup: {
          from: 'order_details',
          localField: '_id',
          foreignField: 'MaHoaDonBan',
          as: 'items',
        },
      },
      {
        $lookup: {
          from: 'customers',
          localField: 'MaKH',
          foreignField: '_id',
          as: 'khachhang',
        },
      },
      { $sort: { NgayBan: -1 } },
    ]);
    res.json({ success: true, data: orders });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
// @desc    Lấy chi tiết một hóa đơn cụ thể
// @route   GET /api/orders/:id
// @access  Private
const getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('MaKH')
      .lean();
    if (!order) return res.status(404).json({ success: false, message: 'Không tìm thấy' });
    const details = await OrderDetail.find({ MaHoaDonBan: order._id }).populate('MaHH');
    order.items = details;
    res.json({ success: true, data: order });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
module.exports = { createOrder, getOrders, getOrderById };