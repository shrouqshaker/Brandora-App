const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
    name: { type: String, required: true, trim: true },
    quantity: { type: Number, required: true, min: 0 },
    price: { type: Number, required: true, min: 0 },
    imagePath: { type: String, default: null },
    includesMaterials: { type: Boolean, default: true },
    usedMaterials: [{ type: String }],    // stored as MaterialName  qty strings
    ownerId: { type: String, required: true },   // Firebase UID
}, { timestamps: true });

module.exports = mongoose.model('Product', productSchema);