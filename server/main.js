require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');
const seedDatabase = require('./utils/seed');

const app = express();
const PORT = process.env.PORT || 3000;

// ─── Middleware ─────────────────────────────────────────────
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ─── Routes ─────────────────────────────────────────────────
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/categories', require('./routes/categoryRoutes'));
app.use('/api/products', require('./routes/productRoutes'));
app.use('/api/customers', require('./routes/customerRoutes'));
app.use('/api/orders', require('./routes/orderRoutes'));
app.use('/api/report', require('./routes/reportRoutes'));

// ─── API Documentation ─────────────────────────────────────────
app.get('/api', (req, res) => {
  res.json({
    success: true,
    message: '📖 CONU Bookstore API Documentation',
    endpoints: {
      auth: {
        base: '/api/auth',
        methods: [
          { method: 'POST', path: '/login', description: 'Đăng nhập hệ thống' },
          { method: 'GET', path: '/me', description: 'Lấy thông tin profile hiện tại', secure: true },
          { method: 'PUT', path: '/change-password', description: 'Đổi mật khẩu', secure: true },
        ],
      },
      products: {
        base: '/api/products',
        methods: [
          { method: 'GET', path: '/', description: 'Lấy danh sách sản phẩm', secure: true },
          { method: 'GET', path: '/:id', description: 'Lấy chi tiết sản phẩm', secure: true },
          { method: 'POST', path: '/', description: 'Tạo sản phẩm mới', secure: true },
          { method: 'PUT', path: '/:id', description: 'Cập nhật sản phẩm', secure: true },
          { method: 'DELETE', path: '/:id', description: 'Xóa sản phẩm', secure: true },
          { method: 'PATCH', path: '/:id/stock', description: 'Cập nhật tồn kho (tăng/giảm)', secure: true },
        ],
      },
      categories: {
        base: '/api/categories',
        methods: [
          { method: 'GET', path: '/', description: 'Lấy danh sách danh mục', secure: true },
          { method: 'GET', path: '/:id', description: 'Lấy chi tiết danh mục', secure: true },
          { method: 'POST', path: '/', description: 'Tạo danh mục mới', secure: true },
          { method: 'PUT', path: '/:id', description: 'Cập nhật danh mục', secure: true },
          { method: 'DELETE', path: '/:id', description: 'Xóa danh mục', secure: true },
        ],
      },
      customers: {
        base: '/api/customers',
        methods: [
          { method: 'GET', path: '/', description: 'Lấy danh sách khách hàng', secure: true },
          { method: 'GET', path: '/:id', description: 'Lấy chi tiết khách hàng', secure: true },
          { method: 'POST', path: '/', description: 'Tạo khách hàng mới', secure: true },
          { method: 'PUT', path: '/:id', description: 'Cập nhật khách hàng', secure: true },
          { method: 'DELETE', path: '/:id', description: 'Xóa khách hàng', secure: true },
        ],
      },
      orders: {
        base: '/api/orders',
        methods: [
          { method: 'GET', path: '/', description: 'Lấy danh sách hóa đơn (kèm chi tiết & khách hàng)', secure: true },
          { method: 'GET', path: '/:id', description: 'Lấy chi tiết hóa đơn cụ thể', secure: true },
          { method: 'POST', path: '/', description: 'Tạo hóa đơn mới và trừ tồn kho', secure: true },
          { method: 'PUT', path: '/:id/status', description: 'Cập nhật trạng thái hóa đơn', secure: true },
        ],
      },
      report: {
        base: '/api/report',
        methods: [
          { method: 'GET', path: '/revenue?startDate=...&endDate=...', description: 'Báo cáo doanh thu & tăng trưởng', secure: true },
          { method: 'GET', path: '/products?startDate=...&endDate=...&type=best|slow', description: 'Báo cáo sản phẩm bán chạy/chậm', secure: true },
        ],
      },
    },
  });
});

app.get('/', (req, res) => {
  res.json({
    success: true,
    message: '🚀 CONU Bookstore API is running!',
    documentation: 'Truy cập /api để xem chi tiết các method',
    version: '1.0.0',
  });
});

// ─── 404 Handler ─────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ success: false, message: `Route ${req.originalUrl} không tồn tại` });
});

// ─── Global Error Handler ─────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('Error:', err.stack);
  res.status(500).json({ success: false, message: 'Lỗi server', error: err.message });
});

// ─── Start Server ─────────────────────────────────────────────
const start = async () => {
  await connectDB();
  await seedDatabase(); 
  app.listen(PORT, () => {
    console.log(`🌐 Server đang chạy tại: http://localhost:${PORT}`);
    console.log(`📖 API docs tại: http://localhost:${PORT}/`);
  });
};

start();