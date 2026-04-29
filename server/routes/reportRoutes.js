const express = require('express');
const router = express.Router();
const { getRevenueReport, getProductReport } = require('../controllers/reportController');
const auth = require('../middleware/auth');
router.get('/revenue', auth, getRevenueReport);
router.get('/products', auth, getProductReport);
module.exports = router;