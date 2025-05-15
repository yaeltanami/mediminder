const express = require('express');
const dotenv = require('dotenv');
const connectDB = require('./config/db');
const reminderService = require('./services/reminderService');  
const { sendLedCommand } = require('./controllers/espController');
const cron = require('node-cron');


dotenv.config();
connectDB();

const app = express();
app.use(express.json());

app.use('/api', require('./routes/api'));

app.get('/', (req, res) => res.send('MediMinder Server Running...'));

const PORT = process.env.PORT || 5050;
app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log("JWT_SECRET:", process.env.JWT_SECRET);
    
  
    // כאן מתבצעת שליחה אוטומטית של פקודת הדלקה ל-ESP כשהשרת עולה
    sendLedCommand("10000")
      .then((result) => {
        console.log("✅ ESP command sent on startup:", result);
      })
      .catch((err) => {
        console.error("❌ Failed to send command to ESP on startup:", err.message);
      });
      
  });
  

