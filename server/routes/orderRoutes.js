const express = require('express');
const router = express.Router();
const { createOrder, getOrders, getOrderById } = require('../controllers/orderController');
const auth = require('../middleware/auth');

// @route   POST /api/orders
// @desc    Tạo hóa đơn mới (tự động tính tổng tiền & trừ tồn kho)
// @access  Private
router.post('/', auth, createOrder);

// @route   GET /api/orders
// @desc    Lấy danh sách hóa đơn (kèm thông tin chi tiết & khách hàng)
// @access  Private
router.get('/', auth, getOrders);

// @route   GET /api/orders/:id
// @desc    Lấy chi tiết một hóa đơn cụ thể (kèm items)
// @access  Private
router.get('/:id', auth, getOrderById);

module.exports = router;
