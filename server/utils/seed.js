const User = require('../models/User');
const Category = require('../models/Category');
const Product = require('../models/Product');
const Customer = require('../models/Customer');
const Order = require('../models/Order');
const OrderDetail = require('../models/OrderDetail');
const bcrypt = require('bcryptjs');

const seedDatabase = async () => {
  try {
    const userCount = await User.countDocuments();
    if (userCount > 0) return; // Already seeded

    console.log('Đang seed dữ liệu mẫu theo cấu trúc mới...');

    // 1. Users
    const hashed = await bcrypt.hash('123456', 10);
    const users = await User.insertMany([
      { TenDangNhap: 'admin', MatKhau: hashed, Quyen: 'admin' },
      { TenDangNhap: 'chu', MatKhau: hashed, Quyen: 'owner' },
    ]);
    console.log('- Tạo 2 tài khoản: admin / chu (mật khẩu: 123456)');

    // 2. Categories
    const categories = await Category.insertMany([
      { MaLoai: 'L001', TenLoai: 'Sách giáo khoa' },
      { MaLoai: 'L002', TenLoai: 'Truyện tranh' },
      { MaLoai: 'L003', TenLoai: 'Văn phòng phẩm' },
    ]);
    console.log('- Tạo 3 loại hàng');

    // 3. Customers
    const customers = await Customer.insertMany([
      { MaKH: 'KH000', TenKH: 'Khách lẻ' },
      { MaKH: 'KH001', TenKH: 'Nguyễn Văn A', SDTKhachHang: '0901234567' },
    ]);
    console.log('- Tạo 2 khách hàng');

    // 4. Products
    const products = await Product.insertMany([
      { MaHH: 'HH001', TenHH: 'Bút Bi Thiên Long', MaVach: '89350001', GiaBan: 5000, LoiNhuan: 2000, SoLuong: 100, MaLoai: categories[2]._id },
      { MaHH: 'HH002', TenHH: 'Sách Toán Lớp 1', MaVach: '89350002', GiaBan: 25000, LoiNhuan: 7000, SoLuong: 50, MaLoai: categories[0]._id },
    ]);
    console.log('- Tạo 2 hàng hóa');

    console.log('Seed hoàn tất!');
  } catch (error) {
    console.error('Lỗi khi seed:', error);
  }
};

module.exports = seedDatabase;
