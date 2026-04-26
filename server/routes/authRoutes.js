const express = require('express');
const router = express.Router();
const { login, getMe, changePassword } = require('../controllers/authController');
const auth = require('../middleware/auth');

// @route   POST /api/auth/login
// @desc    Đăng nhập hệ thống
// @access  Public
router.post('/login', login);

// @route   GET /api/auth/me
// @desc    Lấy thông tin profile hiện tại
// @access  Private
router.get('/me', auth, getMe);

// @route   PUT /api/auth/change-password
// @desc    Đổi mật khẩu
// @access  Private
router.put('/change-password', auth, changePassword);

module.exports = router;
