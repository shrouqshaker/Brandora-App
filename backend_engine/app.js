const express = require('express');
// Triggering new build - 23:35
const mongoose = require('mongoose');
const admin = require('firebase-admin');
const path = require('path');
require('dotenv').config();
const cors = require('cors');

// ─── Firebase Admin ──────────────────────────────────────────────────────────
let serviceAccount;
try {
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
        serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    } else {
        serviceAccount = require('./serviceAccountKey.json');
    }
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    console.log('✅ Firebase Admin Initialized');
} catch (error) {
    console.error('❌ Firebase Admin Initialization Error:', error.message);
    console.error('Make sure FIREBASE_SERVICE_ACCOUNT is set in Railway Variables.');
}

// ─── Express Setup ───────────────────────────────────────────────────────────
const app = express();
app.use(cors());
app.use(express.json());

// Serve uploaded product images as static files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ─── MongoDB ─────────────────────────────────────────────────────────────────
const mongoURI = process.env.MONGO_URL || process.env.MONGO_URI || 'mongodb://localhost:27017/brandora_db';
mongoose.connect(mongoURI)
    .then(() => console.log('✅ Connected to MongoDB'))
    .catch(err => {
        console.error('❌ MongoDB Connection Error:', err.message);
        console.error('Check MONGO_URL in Railway Variables.');
    });

// ─── Routes ──────────────────────────────────────────────────────────────────
const materialRoutes = require('./routes/materialRoutes');
const productRoutes = require('./routes/productRoutes');
const userRoutes = require('./routes/userRoutes');
const orderRoutes = require('./routes/orderRoutes');

app.use('/api/materials', materialRoutes);
app.use('/api/products', productRoutes);
app.use('/api/users', userRoutes);
app.use('/api/orders', orderRoutes);

app.get('/api/test', (req, res) => res.json({ message: 'API is working!' }));

app.get('/', (req, res) => res.json({ status: 'Brandora Backend v2.0 - LIVE', routes: ['/api/users/profile', '/api/users/role', '/api/materials', '/api/products', '/api/orders'] }));

// ─── Global Error Handler ────────────────────────────────────────────────────
app.use((err, req, res, next) => {
    console.error('Unhandled Error:', err.message);
    res.status(500).json({ message: err.message || 'Internal server error' });
});

// ─── Start Server ─────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 8080;
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on port ${PORT}`));