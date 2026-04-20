const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const Product = require('../models/Product');
const verifyToken = require('../middleware/authMiddleware');

router.use(verifyToken);

// Customer places an order
router.post('/', async (req, res) => {
    try {
        const { productId, quantity, customerName, customerPhone } = req.body;
        
        const product = await Product.findById(productId);
        if (!product) return res.status(404).json({ message: 'Product not found.' });

        const order = new Order({
            customerId: req.user.uid,
            sellerId: product.ownerId,
            productId: product._id,
            productName: product.name,
            quantity: Number(quantity),
            totalPrice: product.price * Number(quantity),
            customerName,
            customerPhone,
        });

        await order.save();
        res.status(201).json(order);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Get orders (Seller sees their products' orders, Customer sees their own orders)
router.get('/', async (req, res) => {
    try {
        const { role } = req.query; // Expect role to be passed from frontend for filtering or check DB
        
        let query = {};
        if (role === 'seller') {
            query = { sellerId: req.user.uid };
        } else {
            query = { customerId: req.user.uid };
        }

        const orders = await Order.find(query).sort({ createdAt: -1 });
        res.json(orders);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
