const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Initialize Firebase Admin (Only if service account is provided)
// Ideally, download serviceAccountKey.json from Firebase Console -> Project Settings -> Service Accounts
// and place it in this folder.
const serviceAccountPath = './serviceAccountKey.json';
try {
    const serviceAccount = require(serviceAccountPath);
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
    console.log("🔥 Firebase Admin SDK initialized successfully.");
} catch (error) {
    console.warn("⚠️  Firebase Admin SDK NOT initialized. Download serviceAccountKey.json to enable Firebase features.");
    console.warn("Error: " + error.message);
}

// Routes
app.get('/', (req, res) => {
    res.send('<h1>E-Learning Backend API is Running 🚀</h1><p>Status: Online</p>');
});

app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date() });
});

// Example: Get Users (Needs Admin SDK)
app.get('/api/admin/users', async (req, res) => {
    if (!admin.apps.length) {
        return res.status(503).json({ error: "Firebase Admin not initialized." });
    }
    try {
        const listUsersResult = await admin.auth().listUsers(10);
        res.json(listUsersResult.users);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Start Server
app.listen(PORT, () => {
    console.log(`✅ Server is running on http://localhost:${PORT}`);
});
