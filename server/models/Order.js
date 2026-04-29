// Model d?i di?n cho hÛa don b·n h‡ng
const mongoose = require('mongoose');
const OrderSchema = new mongoose.Schema(
  {
    MaHoaDonBan: {
      type: String,
      required: true,
      unique: true,
    },
    NgayBan: {
      type: Date,
      default: Date.now,
    },
    ChietKhau: {
      type: Number,
      default: 0,
    },
    TongThanhTien: {
      type: Number,
      required: true,
    },
    PhuongThucThanhToan: {
      type: String,
      default: 'Ti·ªÅn m·∫∑t',
    },
    MaKH: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Customer',
    },
    customerName: {
      type: String,
      default: 'Kh√°ch l·∫ª',
    },
    customerCode: {
      type: String,
    },
  },
  { timestamps: true, collection: 'orders' }
);
module.exports = mongoose.model('Order', OrderSchema);
