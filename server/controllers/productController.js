const Product = require('../models/Product');

// @desc    Lấy danh sách sản phẩm
// @route   GET /api/products
// @access  Private
const getProducts = async (req, res) => {
  try {
    console.log('--- GET PRODUCTS ---');
    const products = await Product.find().populate('MaLoai').sort({ createdAt: 1 });
    console.log(`Found ${products.length} products`);
    res.json({ success: true, data: products });
  } catch (error) {
    console.error('ERROR IN getProducts:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};
// @desc    Lấy chi tiết một sản phẩm
// @route   GET /api/products/:id
// @access  Private
const getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id).populate('MaLoai');
    if (!product) return res.status(404).json({ success: false, message: 'Không tìm thấy' });
    res.json({ success: true, data: product });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
// @desc    Tạo sản phẩm mới
// @route   POST /api/products
// @access  Private
const createProduct = async (req, res) => {
  try {
    if (!req.body.MaHH) {
      const count = await Product.countDocuments();
      req.body.MaHH = `HH${(count + 1).toString().padStart(5, '0')}`;
    }
    const product = new Product(req.body);
    await product.save();
    res.status(201).json({ success: true, data: product });
  } catch (error) {
    console.error('ERROR IN createProduct:', error);
    res.status(400).json({ success: false, message: error.message });
  }
};
// @desc    Cập nhật thông tin sản phẩm
// @route   PUT /api/products/:id
// @access  Private
const updateProduct = async (req, res) => {
  try {
    delete req.body.MaHH;
    const product = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!product) return res.status(404).json({ success: false, message: 'Không tìm thấy hàng hóa' });
    res.json({ success: true, data: product });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
// @desc    Xóa sản phẩm
// @route   DELETE /api/products/:id
// @access  Private
const deleteProduct = async (req, res) => {
  try {
    await Product.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Xóa thành công' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
// @desc    Cập nhật tồn kho (tăng/giảm số lượng)
// @route   PATCH /api/products/:id/stock
// @access  Private
const updateStock = async (req, res) => {
  try {
    const { amount } = req.body;
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ success: false, message: 'Không tìm thấy' });
    product.SoLuong += amount;
    await product.save();
    res.json({ success: true, data: product });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
module.exports = { createProduct, getProducts, getProductById, updateProduct, deleteProduct, updateStock };