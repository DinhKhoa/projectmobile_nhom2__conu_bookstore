const express = require('express');
const router = express.Router();
const { getProducts, getProductById, createProduct, updateProduct, deleteProduct, updateStock } = require('../controllers/productController');
const auth = require('../middleware/auth');

// @route   GET /api/products
// @desc    Lấy danh sách sản phẩm
// @access  Private
router.get('/', auth, getProducts);

// @route   GET /api/products/:id
// @desc    Lấy chi tiết một sản phẩm
// @access  Private
router.get('/:id', auth, getProductById);

// @route   POST /api/products
// @desc    Tạo sản phẩm mới
// @access  Private
router.post('/', auth, createProduct);

// @route   PUT /api/products/:id
// @desc    Cập nhật thông tin sản phẩm
// @access  Private
router.put('/:id', auth, updateProduct);

// @route   DELETE /api/products/:id
// @desc    Xóa sản phẩm
// @access  Private
router.delete('/:id', auth, deleteProduct);

// @route   PATCH /api/products/:id/stock
// @desc    Cập nhật số lượng tồn kho (amount có thể âm hoặc dương)
// @access  Private
router.patch('/:id/stock', auth, updateStock);

module.exports = router;
