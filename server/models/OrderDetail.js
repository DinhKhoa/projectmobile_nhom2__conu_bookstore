// Model d?i di?n cho chi ti?t hóa don bán hàng
const mongoose = require('mongoose');
const OrderDetailSchema = new mongoose.Schema(
  {
    MaCTHoaDonBan: {
      type: String,
      required: true,
      unique: true,
    },
    SoLuongBan: {
      type: Number,
      required: true,
    },
    ThanhTien: {
      type: Number,
      required: true,
    },
    MaHoaDonBan: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Order',
      required: true,
    },
    MaHH: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Product',
      required: true,
    },
  },
  { timestamps: true, collection: 'order_details' }
);
module.exports = mongoose.model('OrderDetail', OrderDetailSchema);
