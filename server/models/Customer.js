const mongoose = require('mongoose');

const CustomerSchema = new mongoose.Schema(
  {
    MaKH: {
      type: String,
      required: true,
      unique: true,
    },
    TenKH: {
      type: String,
      required: true,
    },
    DiaChiKhachHang: {
      type: String,
      default: '',
    },
    SDTKhachHang: {
      type: String,
      default: '',
    },
  },
  { timestamps: true, collection: 'customers' }
);

module.exports = mongoose.model('Customer', CustomerSchema);
