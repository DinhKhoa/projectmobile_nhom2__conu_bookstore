const mongoose = require('mongoose');

const CategorySchema = new mongoose.Schema(
  {
    MaLoai: {
      type: String,
      required: true,
      unique: true,
    },
    TenLoai: {
      type: String,
      required: true,
    },
    TrangThai: {
      type: String,
      default: 'active',
    },
  },
  { timestamps: true, collection: 'categories' }
);

module.exports = mongoose.model('Category', CategorySchema);
