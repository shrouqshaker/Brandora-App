const mongoose = require('mongoose');

const materialSchema = new mongoose.Schema({
    name: { type: String, required: true, trim: true },
    quantity: { type: Number, required: true, default: 0, min: 0 },
    unit: { type: String, enum: ['kg', 'piece', 'liter', 'meter'], required: true },
    price: { type: Number, required: true, min: 0 },
    ownerId: { type: String, required: true },   // Firebase UID
}, { timestamps: true });

module.exports = mongoose.model('Material', materialSchema);