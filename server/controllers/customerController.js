const Customer = require('../models/Customer');

// @desc    Tạo khách hàng mới
// @route   POST /api/customers
// @access  Private
const createCustomer = async (req, res) => {
  try {
    const { SDTKhachHang } = req.body;
    if (SDTKhachHang && SDTKhachHang.length !== 10) {
      return res.status(400).json({ success: false, message: 'Số điện thoại phải có đúng 10 chữ số' });
    }
    const existingCustomer = await Customer.findOne({ SDTKhachHang });
    if (existingCustomer) {
      return res.status(400).json({ success: false, message: 'Số điện thoại này đã tồn tại trên hệ thống' });
    }
    if (!req.body.MaKH) {
      const count = await Customer.countDocuments();
      req.body.MaKH = `KH${(count + 1).toString().padStart(5, '0')}`;
    }
    const customer = new Customer(req.body);
    await customer.save();
    res.status(201).json({ success: true, data: customer });
  } catch (error) {
    console.error('ERROR IN createCustomer:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};
// @desc    Lấy danh sách tất cả khách hàng
// @route   GET /api/customers
// @access  Private
const getCustomers = async (req, res) => {
  try {
    const customers = await Customer.find().sort({ createdAt: 1 });
    res.json({ success: true, data: customers });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
// @desc    Lấy chi tiết một khách hàng
// @route   GET /api/customers/:id
// @access  Private
const getCustomerById = async (req, res) => {
  try {
    const customer = await Customer.findById(req.params.id);
    if (!customer) return res.status(404).json({ success: false, message: 'Không tìm thấy' });
    res.json({ success: true, data: customer });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
// @desc    Cập nhật thông tin khách hàng
// @route   PUT /api/customers/:id
// @access  Private
const updateCustomer = async (req, res) => {
  try {
    const { SDTKhachHang } = req.body;
    delete req.body.MaKH;
    if (SDTKhachHang && SDTKhachHang.length !== 10) {
      return res.status(400).json({ success: false, message: 'Số điện thoại phải có đúng 10 chữ số' });
    }
    if (SDTKhachHang) {
      const existing = await Customer.findOne({ SDTKhachHang, _id: { $ne: req.params.id } });
      if (existing) {
        return res.status(400).json({ success: false, message: 'Số điện thoại này đã được sử dụng bởi khách hàng khác' });
      }
    }
    const customer = await Customer.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!customer) return res.status(404).json({ success: false, message: 'Không tìm thấy khách hàng' });
    res.json({ success: true, data: customer });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
// @desc    Xóa khách hàng
// @route   DELETE /api/customers/:id
// @access  Private
const deleteCustomer = async (req, res) => {
  try {
    await Customer.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Xóa thành công' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
module.exports = { createCustomer, getCustomers, getCustomerById, updateCustomer, deleteCustomer };