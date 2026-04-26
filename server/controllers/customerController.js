const Customer = require('../models/Customer');

const generateCustomerCode = async () => {
  const customers = await Customer.find({ MaKH: { $regex: /^KH\d+$/ } }, 'MaKH');
  const maxNumber = customers.reduce((max, customer) => {
    const match = customer.MaKH.match(/^KH(\d+)$/);
    if (!match) return max;
    const value = parseInt(match[1], 10);
    return Number.isNaN(value) ? max : Math.max(max, value);
  }, 0);
  return `KH${maxNumber + 1}`;
};

const createCustomer = async (req, res) => {
  try {
    const { MaKH, TenKH, DiaChiKhachHang, SDTKhachHang } = req.body;
    let customerCode = MaKH;
    if (!customerCode || !/^KH\d+$/.test(customerCode)) {
      customerCode = await generateCustomerCode();
    }
    const customer = new Customer({ MaKH: customerCode, TenKH, DiaChiKhachHang, SDTKhachHang });
    await customer.save();
    res.status(201).json({ success: true, data: customer });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getCustomers = async (req, res) => {
  try {
    const customers = await Customer.find();
    res.json({ success: true, data: customers });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getCustomerById = async (req, res) => {
  try {
    const customer = await Customer.findById(req.params.id);
    if (!customer) return res.status(404).json({ success: false, message: 'Không tìm thấy' });
    res.json({ success: true, data: customer });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const updateCustomer = async (req, res) => {
  try {
    const customer = await Customer.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json({ success: true, data: customer });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const deleteCustomer = async (req, res) => {
  try {
    await Customer.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Xóa thành công' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { createCustomer, getCustomers, getCustomerById, updateCustomer, deleteCustomer };
