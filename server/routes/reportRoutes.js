const express = require('express');
const router = express.Router();
const { getRevenueReport, getProductReport } = require('../controllers/reportController');
const auth = require('../middleware/auth');

// @route   GET /api/report/revenue
// @desc    Báo cáo doanh thu & tăng trưởng (query: startDate, endDate dạng dd/mm/yyyy)
// @access  Private
router.get('/revenue', auth, getRevenueReport);

// @route   GET /api/report/products
// @desc    Báo cáo sản phẩm (query: startDate, endDate, type=best|slow)
// @access  Private
router.get('/products', auth, getProductReport);

module.exports = router;
