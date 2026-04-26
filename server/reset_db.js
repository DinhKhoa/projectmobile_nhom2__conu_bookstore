const mongoose = require('mongoose');
const User = require('./models/User');
const Category = require('./models/Category');
const Product = require('./models/Product');
const Customer = require('./models/Customer');
const Order = require('./models/Order');
const OrderDetail = require('./models/OrderDetail');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const resetDB = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI || 'mongodb+srv://vanvo3788_buser:VaNVieT@quanlycuahangvanphongph.cnhcvew.mongodb.net/conu_bookstore?appName=quanlycuahangvanphongpham';
    await mongoose.connect(mongoUri);
    console.log('Connected to MongoDB. DROPPING ALL TABLES (Vietnamese & English)...');

    const db = mongoose.connection.db;
    
    // Explicitly drop old Vietnamese collections if they exist
    const oldCollections = [
      'TAIKHOAN', 'LOAIHANG', 'KHACHHANG', 'HANGHOA', 'HOADONBAN', 'CHITIETHOADONBAN'
    ];
    
    for (const collName of oldCollections) {
      try {
        await db.collection(collName).drop();
        console.log(`- Dropped old collection: ${collName}`);
      } catch (e) {
        // Collection might not exist, ignore
      }
    }

    // Clear new English collections
    await Promise.all([
      User.deleteMany({}),
      Category.deleteMany({}),
      Product.deleteMany({}),
      Customer.deleteMany({}),
      Order.deleteMany({}),
      OrderDetail.deleteMany({}),
    ]);

    console.log('Database cleared. Generating new sample data...');

    // 1. Users (users)
    const adminPass = await bcrypt.hash('123456', 10);
    const users = await User.insertMany([
      { TenDangNhap: 'admin', MatKhau: adminPass, Quyen: 'admin' },
      { TenDangNhap: 'chu', MatKhau: adminPass, Quyen: 'owner' },
    ]);
    console.log('- Created 2 users: admin / chu (password: 123456)');

    // 2. Category (categories)
    const categories = await Category.insertMany([
      { MaLoai: 'L001', TenLoai: 'Sách giáo khoa', TrangThai: 'active' },
      { MaLoai: 'L002', TenLoai: 'Truyện tranh', TrangThai: 'active' },
      { MaLoai: 'L003', TenLoai: 'Văn phòng phẩm', TrangThai: 'active' },
      { MaLoai: 'L004', TenLoai: 'Sách tham khảo', TrangThai: 'active' },
    ]);
    console.log('- Created 4 categories');

    // 3. Customer (customers)
    const customers = await Customer.insertMany([
      { MaKH: 'KH000', TenKH: 'Khách lẻ', DiaChiKhachHang: '', SDTKhachHang: '' },
      { MaKH: 'KH001', TenKH: 'Nguyễn Văn A', DiaChiKhachHang: 'Hà Nội', SDTKhachHang: '0901234567' },
      { MaKH: 'KH002', TenKH: 'Trần Thị B', DiaChiKhachHang: 'TP.HCM', SDTKhachHang: '0912345678' },
    ]);
    console.log('- Created 3 customers');

    // 4. Product (products)
    const products = await Product.insertMany([
      { MaHH: 'HH001', TenHH: 'Bút Bi Thiên Long', MaVach: '89350001', DonViTinh: 'cây', GiaBan: 5000, LoiNhuan: 2000, SoLuong: 100, MaLoai: categories[2]._id },
      { MaHH: 'HH002', TenHH: 'Vở 4 Ô Ly 96 Trang', MaVach: '89350002', DonViTinh: 'cuốn', GiaBan: 12000, LoiNhuan: 5000, SoLuong: 200, MaLoai: categories[2]._id },
      { MaHH: 'HH003', TenHH: 'Toán Lớp 1 - Tập 1', MaVach: '89350003', DonViTinh: 'cuốn', GiaBan: 25000, LoiNhuan: 7000, SoLuong: 50, MaLoai: categories[0]._id },
      { MaHH: 'HH004', TenHH: 'Doraemon - Tập 1', MaVach: '89350004', DonViTinh: 'cuốn', GiaBan: 18000, LoiNhuan: 6000, SoLuong: 80, MaLoai: categories[1]._id },
      { MaHH: 'HH005', TenHH: 'Bút Chì 2B G Star', MaVach: '89350005', DonViTinh: 'cây', GiaBan: 4000, LoiNhuan: 1500, SoLuong: 300, MaLoai: categories[2]._id },
    ]);
    console.log('- Created 5 products');

    // 5. Order & OrderDetail (orders & order_details)
    const startDate = new Date(2026, 0, 1);
    const today = new Date(2026, 3, 4); 
    let orderCount = 0;

    for (let d = new Date(startDate); d <= today; d.setDate(d.getDate() + 1)) {
      const dailyOrders = 1 + Math.floor(Math.random() * 3);
      for (let i = 0; i < dailyOrders; i++) {
        orderCount++;
        const soldAt = new Date(d);
        soldAt.setHours(8 + Math.floor(Math.random() * 12), Math.floor(Math.random() * 60));

        const cust = customers[Math.floor(Math.random() * customers.length)];
        const orderCode = `HDB${soldAt.getFullYear()}${String(soldAt.getMonth() + 1).padStart(2, '0')}${String(soldAt.getDate()).padStart(2, '0')}${String(orderCount).padStart(4, '0')}`;

        const numItems = 1 + Math.floor(Math.random() * 3);
        let tongThanhTien = 0;
        const selectedProducts = [...products].sort(() => 0.5 - Math.random()).slice(0, numItems);

        const newOrder = new Order({
          MaHoaDonBan: orderCode,
          NgayBan: soldAt,
          ChietKhau: Math.random() > 0.8 ? 5000 : 0,
          TongThanhTien: 0,
          TrangThai: 'Hoàn thành',
          PhuongThucThanhToan: Math.random() > 0.3 ? 'Tiền mặt' : 'Chuyển khoản',
          MaKH: cust._id,
        });

        const details = [];
        for (const p of selectedProducts) {
          const qty = 1 + Math.floor(Math.random() * 3);
          const thanhTien = qty * p.GiaBan;
          tongThanhTien += thanhTien;

          details.push({
            MaCTHoaDonBan: `CT${orderCode}${p.MaHH}`,
            SoLuongBan: qty,
            ThanhTien: thanhTien,
            MaHoaDonBan: newOrder._id,
            MaHH: p._id,
          });
        }

        newOrder.TongThanhTien = tongThanhTien - newOrder.ChietKhau;
        await newOrder.save();
        await OrderDetail.insertMany(details);
      }
    }

    console.log(`- Created ${orderCount} orders and order details from 01/01/2026 to today.`);
    console.log('Database clean and reset successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error resetting DB:', error);
    process.exit(1);
  }
};

resetDB();
