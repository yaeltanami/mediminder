const mongoose = require('mongoose'); // ייבוא mongoose לניהול מסד הנתונים
require('dotenv').config(); // טעינת משתני סביבה מקובץ .env

const connectDB = async () => {
    try {
        const conn = await mongoose.connect(process.env.MONGO_URI);
        console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
    } catch (err) {
        console.error(`❌ Error: ${err.message}`);
        process.exit(1);
    }
};

// ייצוא הפונקציה כדי שנוכל להשתמש בה ב-server.js
module.exports = connectDB;
