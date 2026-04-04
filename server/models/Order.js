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
    TrangThai: {
      type: String,
      enum: ['Hoàn thành', 'Đã hủy', 'Đang xử lý'],
      default: 'Hoàn thành',
    },
    PhuongThucThanhToan: {
      type: String,
      default: 'Tiền mặt',
    },
    MaKH: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Customer',
    },
    note: {
      type: String,
      default: '',
    },
  },
  { timestamps: true, collection: 'orders' }
);

module.exports = mongoose.model('Order', OrderSchema);
