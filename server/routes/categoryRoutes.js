const express = require('express');
const router = express.Router();
const { getCategories, getCategoryById, createCategory, updateCategory, deleteCategory } = require('../controllers/categoryController');
const auth = require('../middleware/auth');

// @route   GET /api/categories
// @desc    Lấy danh sách các danh mục (loại hàng)
// @access  Private
router.get('/', auth, getCategories);

// @route   GET /api/categories/:id
// @desc    Lấy chi tiết danh mục
// @access  Private
router.get('/:id', auth, getCategoryById);

// @route   POST /api/categories
// @desc    Tạo danh mục mới
// @access  Private
router.post('/', auth, createCategory);

// @route   PUT /api/categories/:id
// @desc    Cập nhật danh mục
// @access  Private
router.put('/:id', auth, updateCategory);

// @route   DELETE /api/categories/:id
// @desc    Xóa danh mục
// @access  Private
router.delete('/:id', auth, deleteCategory);

module.exports = router;
