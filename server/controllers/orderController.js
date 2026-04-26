const Order = require('../models/Order');
const OrderDetail = require('../models/OrderDetail');
const Product = require('../models/Product');

const getNextOrderCode = async (date = new Date()) => {
  const datePart = date.toISOString().slice(0, 10).replace(/-/g, '');
  const regex = new RegExp(`^HDB${datePart}(\\d+)$`);
  const matchingOrders = await Order.find({ MaHoaDonBan: regex }).select('MaHoaDonBan');

  let nextSequence = 1;
  for (const order of matchingOrders) {
    const match = order.MaHoaDonBan.match(/(\\d+)$/);
    if (match) {
      const sequence = parseInt(match[1], 10);
      if (!Number.isNaN(sequence) && sequence >= nextSequence) {
        nextSequence = sequence + 1;
      }
    }
  }

  return `HDB${datePart}${String(nextSequence).padStart(3, '0')}`;
};

const createOrder = async (req, res) => {
  try {
    const { MaKH, items, ChietKhau = 0, PhuongThucThanhToan, note } = req.body;

    if (!items || items.length === 0) {
      return res.status(400).json({ success: false, message: 'Đơn hàng phải có ít nhất 1 sản phẩm' });
    }

    // 1. Tạo Hóa Đơn Bán (Header)
    const MaHoaDonBan = await getNextOrderCode();

    const order = new Order({
      MaHoaDonBan,
      NgayBan: new Date(),
      ChietKhau,
      TongThanhTien: 0, // Tính sau khi lưu chi tiết
      PhuongThucThanhToan: PhuongThucThanhToan || 'Tiền mặt',
      MaKH: MaKH || null,
      note: note || '',
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
      {
        $unwind: {
          path: '$items',
          preserveNullAndEmptyArrays: true,
        },
      },
      {
        $lookup: {
          from: 'products',
          localField: 'items.MaHH',
          foreignField: '_id',
          as: 'items.product',
        },
      },
      {
        $unwind: {
          path: '$items.product',
          preserveNullAndEmptyArrays: true,
        },
      },
      {
        $group: {
          _id: '$_id',
          MaHoaDonBan: { $first: '$MaHoaDonBan' },
          NgayBan: { $first: '$NgayBan' },
          ChietKhau: { $first: '$ChietKhau' },
          TongThanhTien: { $first: '$TongThanhTien' },
          TrangThai: { $first: '$TrangThai' },
          PhuongThucThanhToan: { $first: '$PhuongThucThanhToan' },
          MaKH: { $first: '$MaKH' },
          note: { $first: '$note' },
          createdAt: { $first: '$createdAt' },
          updatedAt: { $first: '$updatedAt' },
          khachhang: { $first: '$khachhang' },
          items: {
            $push: {
              $cond: {
                if: { $ne: ['$items', null] },
                then: {
                  _id: '$items._id',
                  MaCTHoaDonBan: '$items.MaCTHoaDonBan',
                  SoLuongBan: '$items.SoLuongBan',
                  ThanhTien: '$items.ThanhTien',
                  MaHoaDonBan: '$items.MaHoaDonBan',
                  MaHH: '$items.product',
                },
                else: null,
              },
            },
          },
        },
      },
      {
        $project: {
          items: {
            $filter: {
              input: '$items',
              as: 'item',
              cond: { $ne: ['$$item', null] },
            },
          },
          MaHoaDonBan: 1,
          NgayBan: 1,
          ChietKhau: 1,
          TongThanhTien: 1,
          TrangThai: 1,
          PhuongThucThanhToan: 1,
          MaKH: { $arrayElemAt: ['$khachhang', 0] },
          note: 1,
          createdAt: 1,
          updatedAt: 1,
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

const getNextCode = async (req, res) => {
  try {
    const nextCode = await getNextOrderCode();
    res.json({ success: true, data: { nextCode } });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { createOrder, getOrders, getOrderById, getNextCode };
