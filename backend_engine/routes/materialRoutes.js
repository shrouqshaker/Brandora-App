const express = require('express');
const router = express.Router();
const Material = require('../models/Material');
const verifyToken = require('../middleware/authMiddleware');

// All material routes require authentication
router.use(verifyToken);

// ─── GET all materials for the authenticated user ────────────────────────────
router.get('/', async (req, res) => {
    try {
        const materials = await Material.find({ ownerId: req.user.uid }).sort({ createdAt: -1 });
        res.json(materials);
    } catch (err) {
        res.status(500).json({ message: 'Failed to fetch materials: ' + err.message });
    }
});

// ─── POST create a new material ──────────────────────────────────────────────
router.post('/', async (req, res) => {
    try {
        const { name, quantity, unit, price } = req.body;

        // Validation
        if (!name || name.trim() === '')
            return res.status(400).json({ message: 'Material name is required.' });
        if (quantity === undefined || isNaN(quantity) || Number(quantity) < 0)
            return res.status(400).json({ message: 'A valid quantity is required.' });
        if (!unit)
            return res.status(400).json({ message: 'Unit is required.' });
        if (price === undefined || isNaN(price) || Number(price) < 0)
            return res.status(400).json({ message: 'A valid price is required.' });

        const newMaterial = new Material({
            name: name.trim(),
            quantity: Number(quantity),
            unit,
            price: Number(price),
            ownerId: req.user.uid,
        });

        const saved = await newMaterial.save();
        res.status(201).json(saved);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// ─── PUT update a material by ID ─────────────────────────────────────────────
router.put('/:id', async (req, res) => {
    try {
        const { name, quantity, unit, price } = req.body;

        const material = await Material.findOne({ _id: req.params.id, ownerId: req.user.uid });
        if (!material) return res.status(404).json({ message: 'Material not found.' });

        if (name !== undefined) material.name = name.trim();
        if (quantity !== undefined) material.quantity = Number(quantity);
        if (unit !== undefined) material.unit = unit;
        if (price !== undefined) material.price = Number(price);

        const updated = await material.save();
        res.json(updated);
    } catch (err) {
        res.status(400).json({ message: 'Update failed: ' + err.message });
    }
});

// ─── PATCH update quantity only (deduct/add during production) ───────────────
router.patch('/:id/quantity', async (req, res) => {
    try {
        const { quantityChange } = req.body;  // positive = add, negative = deduct
        if (quantityChange === undefined || isNaN(quantityChange))
            return res.status(400).json({ message: 'quantityChange is required.' });

        const material = await Material.findOne({ _id: req.params.id, ownerId: req.user.uid });
        if (!material) return res.status(404).json({ message: 'Material not found.' });

        material.quantity = Math.max(0, material.quantity + Number(quantityChange));
        const updated = await material.save();
        res.json(updated);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// ─── DELETE a material by ID ─────────────────────────────────────────────────
router.delete('/:id', async (req, res) => {
    try {
        const deleted = await Material.findOneAndDelete({ _id: req.params.id, ownerId: req.user.uid });
        if (!deleted) return res.status(404).json({ message: 'Material not found.' });
        res.json({ message: 'Material deleted successfully.' });
    } catch (err) {
        res.status(500).json({ message: 'Delete failed: ' + err.message });
    }
});

module.exports = router;