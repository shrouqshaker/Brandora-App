const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const verifyToken = require('../middleware/authMiddleware');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// All product routes require authentication
router.use(verifyToken);

// ─── Multer setup for image uploads ─────────────────────────────────────────
const uploadDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, uploadDir),
    filename: (req, file, cb) => {
        const unique = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
        cb(null, `${unique}${path.extname(file.originalname)}`);
    },
});

const upload = multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        cb(null, true);
    },
});

// ─── GET products (Customer sees ALL, Seller sees OWN) ────────────────────────
router.get('/', async (req, res) => {
    try {
        const { role } = req.query; // Expect role to be passed from frontend
        
        let query = {};
        if (role === 'seller') {
            query = { ownerId: req.user.uid };
        }
        // if role is customer or not provided, show all products

        const products = await Product.find(query).sort({ createdAt: -1 });
        res.json(products);
    } catch (err) {
        res.status(500).json({ message: 'Failed to fetch products: ' + err.message });
    }
});

// ─── POST create a product (multipart/form-data with optional image) ─────────
router.post('/', upload.single('image'), async (req, res) => {
    try {
        const { name, quantity, price, includesMaterials, usedMaterials } = req.body;

        // Validation
        if (!name || name.trim() === '')
            return res.status(400).json({ message: 'Product name is required.' });
        if (quantity === undefined || isNaN(quantity) || Number(quantity) < 0)
            return res.status(400).json({ message: 'A valid quantity is required.' });
        if (price === undefined || isNaN(price) || Number(price) < 0)
            return res.status(400).json({ message: 'A valid price is required.' });

        // usedMaterials is sent as JSON string from Flutter
        let parsedMaterials = [];
        if (usedMaterials) {
            try { parsedMaterials = JSON.parse(usedMaterials); } catch (_) { parsedMaterials = []; }
        }

        const newProduct = new Product({
            name: name.trim(),
            quantity: Number(quantity),
            price: Number(price),
            imagePath: req.file ? `uploads/${req.file.filename}` : null,
            includesMaterials: includesMaterials === 'true' || includesMaterials === true,
            usedMaterials: parsedMaterials,
            ownerId: req.user.uid,
        });

        const saved = await newProduct.save();
        res.status(201).json(saved);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// ─── DELETE a product by ID ───────────────────────────────────────────────────
router.delete('/:id', async (req, res) => {
    try {
        const deleted = await Product.findOneAndDelete({ _id: req.params.id, ownerId: req.user.uid });
        if (!deleted) return res.status(404).json({ message: 'Product not found.' });

        // Remove image file if it exists
        if (deleted.imagePath) {
            const imgPath = path.join(__dirname, '..', deleted.imagePath);
            if (fs.existsSync(imgPath)) fs.unlinkSync(imgPath);
        }

        res.json({ message: 'Product deleted successfully.' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;