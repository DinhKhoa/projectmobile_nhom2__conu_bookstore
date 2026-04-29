// Model đại diện cho danh mục sản phẩm (Loại hàng)
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
  },
  { timestamps: true, collection: 'categories' }
);
module.exports = mongoose.model('Category', CategorySchema);