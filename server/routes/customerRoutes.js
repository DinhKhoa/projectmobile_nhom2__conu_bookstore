const express = require('express');
const router = express.Router();
const { getCustomers, getCustomerById, createCustomer, updateCustomer, deleteCustomer } = require('../controllers/customerController');
const auth = require('../middleware/auth');

// @route   GET /api/customers
// @desc    Lấy danh sách khách hàng
// @access  Private
router.get('/', auth, getCustomers);

// @route   GET /api/customers/:id
// @desc    Lấy thông tin một khách hàng
// @access  Private
router.get('/:id', auth, getCustomerById);

// @route   POST /api/customers
// @desc    Tạo khách hàng mới
// @access  Private
router.post('/', auth, createCustomer);

// @route   PUT /api/customers/:id
// @desc    Cập nhật thông tin khách hàng
// @access  Private
router.put('/:id', auth, updateCustomer);

// @route   DELETE /api/customers/:id
// @desc    Xóa khách hàng
// @access  Private
router.delete('/:id', auth, deleteCustomer);

module.exports = router;
