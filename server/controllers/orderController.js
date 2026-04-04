const Order = require('../models/Order');
const OrderDetail = require('../models/OrderDetail');
const Product = require('../models/Product');

const createOrder = async (req, res) => {
  try {
    const { MaKH, items, ChietKhau = 0, PhuongThucThanhToan, note } = req.body;

    if (!items || items.length === 0) {
      return res.status(400).json({ success: false, message: 'Đơn hàng phải có ít nhất 1 sản phẩm' });
    }

    // 1. Tạo Hóa Đơn Bán (Header)
    const orderCount = await Order.countDocuments();
    const datePart = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const MaHoaDonBan = `HDB${datePart}${String(orderCount + 1).padStart(4, '0')}`;

    const order = new Order({
      MaHoaDonBan,
      NgayBan: new Date(),
      ChietKhau,
      TongThanhTien: 0, // Tính sau khi lưu chi tiết
      PhuongThucThanhToan: PhuongThucThanhToan || 'Tiền mặt',
      MaKH: MaKH || null,
      TrangThai: 'Hoàn thành',
    });

    let tongThanhTien = 0;
    const details = [];

    // 2. Tạo Chi Tiết Hóa Đơn Bán
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

      // Cập nhật tồn kho
      prod.SoLuong -= item.SoLuongBan;
      await prod.save();
    }

    order.TongThanhTien = tongThanhTien - ChietKhau;
    await order.save();
    await OrderDetail.insertMany(details);

    res.status(201).json({ success: true, data: order });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

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
