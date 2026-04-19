const admin = require('../config/firebase-config');

const verifyToken = async (req, res, next) => {
    
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: "Access denied. No token provided." });
    }

    const token = authHeader.split(' ')[1];

    try {
        const decodedToken = await admin.auth().verifyIdToken(token);
        
        
        req.user = decodedToken; 
        
        next(); 
    } catch (error) {
        console.error("Firebase Auth Error:", error.code); 
        
        if (error.code === 'auth/id-token-expired') {
            return res.status(401).json({ error: "Token expired. Please login again." });
        }
        
        res.status(401).json({ error: "Invalid or unauthorized token." });
    }
};

module.exports = verifyToken;