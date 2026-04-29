// Model d?i di?n cho s?n ph?m (Hàng hóa)
const mongoose = require('mongoose');
const ProductSchema = new mongoose.Schema(
  {
    MaHH: {
      type: String,
      required: true,
      unique: true,
    },
    TenHH: {
      type: String,
      required: true,
    },
    MaVach: {
      type: String,
      default: '',
    },
    DonViTinh: {
      type: String,
      default: 'CÃ¡i',
    },
    LoiNhuan: {
      type: Number,
      default: 0,
    },
    GiaBan: {
      type: Number,
      default: 0,
    },
    SoLuong: {
      type: Number,
      default: 0,
    },
    NguongCanhBao: {
      type: Number,
      default: 10,
    },
    TrangThai: {
      type: String,
      default: 'active',
    },
    MaLoai: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Category',
      required: true,
    },
  },
  { timestamps: true, collection: 'products' }
);
module.exports = mongoose.model('Product', ProductSchema);
