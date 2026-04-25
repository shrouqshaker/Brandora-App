const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const Order = require('../models/Order');
const verifyToken = require('../middleware/authMiddleware');

router.use(verifyToken);

// ─── GET /analytics/seller — Real seller analytics ───────────────────────────
router.get('/seller', async (req, res) => {
    try {
        const Material = require('../models/Material'); // Load Material model
        const totalProducts = await Product.countDocuments({ ownerId: req.user.uid });
        const orders = await Order.find({ sellerId: req.user.uid });
        const totalOrders = orders.length;
        const totalRevenue = orders.reduce((sum, order) => sum + (order.totalPrice || 0), 0);

        // Calculate Low Stock Materials (e.g., quantity < 3)
        const lowStockCount = await Material.countDocuments({ 
            ownerId: req.user.uid, 
            quantity: { $lt: 3 } 
        });

        res.json({ totalProducts, totalOrders, totalRevenue, lowStockCount });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
