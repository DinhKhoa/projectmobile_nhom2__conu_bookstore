const Category = require('../models/Category');
// @desc    Tạo danh mục mới
// @route   POST /api/categories
// @access  Private
const createCategory = async (req, res) => {
  try {
    if (!req.body.MaLoai) {
      const count = await Category.countDocuments();
      req.body.MaLoai = `LH${(count + 1).toString().padStart(5, '0')}`;
    }
    const category = new Category(req.body);
    await category.save();
    res.status(201).json({ success: true, data: category });
  } catch (error) {
    console.error('ERROR IN createCategory:', error);
    res.status(400).json({ success: false, message: error.message });
  }
};
// @desc    Lấy danh sách tất cả danh mục
// @route   GET /api/categories
// @access  Private
const getCategories = async (req, res) => {
  try {
    const categories = await Category.find().sort({ createdAt: 1 });
    res.json({ success: true, data: categories });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
// @desc    Lấy thông tin chi tiết một danh mục
// @route   GET /api/categories/:id
// @access  Private
const getCategoryById = async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);
    if (!category) return res.status(404).json({ success: false, message: 'Không tìm thấy' });
    res.json({ success: true, data: category });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
// @desc    Cập nhật thông tin danh mục
// @route   PUT /api/categories/:id
// @access  Private
const updateCategory = async (req, res) => {
  try {
    delete req.body.MaLoai;
    const category = await Category.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!category) return res.status(404).json({ success: false, message: 'Không tìm thấy loại hàng' });
    res.json({ success: true, data: category });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
// @desc    Xóa danh mục
// @route   DELETE /api/categories/:id
// @access  Private
const deleteCategory = async (req, res) => {
  try {
    await Category.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Xóa thành công' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
module.exports = { createCategory, getCategories, getCategoryById, updateCategory, deleteCategory };