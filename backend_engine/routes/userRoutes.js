const express = require('express');
const router = express.Router();
const User = require('../models/User');
const verifyToken = require('../middleware/authMiddleware');

router.use(verifyToken);

// Get current user profile/role
router.get('/profile', async (req, res) => {
    try {
        let user = await User.findOne({ uid: req.user.uid });
        if (!user) {
            // Create user if they don't exist yet (first login)
            user = new User({
                uid: req.user.uid,
                email: req.user.email,
            });
            await user.save();
        }
        res.json(user);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Update user role
router.post('/role', async (req, res) => {
    try {
        const { role } = req.body;
        if (!['customer', 'seller'].includes(role)) {
            return res.status(400).json({ message: 'Invalid role. Choose customer or seller.' });
        }

        const user = await User.findOneAndUpdate(
            { uid: req.user.uid },
            { role, hasSelectedRole: true },
            { new: true, upsert: true }
        );
        res.json(user);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
