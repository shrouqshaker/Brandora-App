const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const Product = require('../models/Product');
const verifyToken = require('../middleware/authMiddleware');

router.use(verifyToken);

// Customer places an order
router.post('/', async (req, res) => {
    try {
        const { productId, quantity, customerName } = req.body;
        
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

// Update order status (Seller only)
router.put('/:id/status', async (req, res) => {
    try {
        const { status } = req.body;
        if (!['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'].includes(status)) {
            return res.status(400).json({ message: 'Invalid status' });
        }

        const order = await Order.findOneAndUpdate(
            { _id: req.params.id, sellerId: req.user.uid },
            { status },
            { new: true }
        );

        if (!order) return res.status(404).json({ message: 'Order not found or not authorized' });

        res.json(order);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Delete an order (Allow customer to cancel/remove if Pending)
router.delete('/:id', async (req, res) => {
    try {
        const order = await Order.findOneAndDelete({
            _id: req.params.id,
            $or: [{ customerId: req.user.uid }, { sellerId: req.user.uid }]
        });

        if (!order) return res.status(404).json({ message: 'Order not found' });
        res.json({ message: 'Order removed successfully' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
