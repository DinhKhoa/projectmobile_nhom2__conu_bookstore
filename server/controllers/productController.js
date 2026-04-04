const Product = require('../models/Product');

const createProduct = async (req, res) => {
  try {
    const { MaHH, TenHH, MaVach, DonViTinh, LoiNhuan, GiaBan, SoLuong, NguongCanhBao, TrangThai, MaLoai } = req.body;
    const product = new Product({ MaHH, TenHH, MaVach, DonViTinh, LoiNhuan, GiaBan, SoLuong, NguongCanhBao, TrangThai, MaLoai });
    await product.save();
    res.status(201).json({ success: true, data: product });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getProducts = async (req, res) => {
  try {
    const products = await Product.find().populate('MaLoai');
    res.json({ success: true, data: products });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id).populate('MaLoai');
    if (!product) return res.status(404).json({ success: false, message: 'Không tìm thấy' });
    res.json({ success: true, data: product });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const updateProduct = async (req, res) => {
  try {
    const product = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json({ success: true, data: product });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const deleteProduct = async (req, res) => {
  try {
    await Product.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Xóa thành công' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

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
