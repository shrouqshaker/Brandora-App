const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    uid: { type: String, required: true, unique: true }, // Firebase UID
    email: { type: String, required: true },
    role: { type: String, enum: ['customer', 'seller'], default: 'customer' },
    hasSelectedRole: { type: Boolean, default: false },
    name: { type: String },
    phone: { type: String },
    createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('User', userSchema);
