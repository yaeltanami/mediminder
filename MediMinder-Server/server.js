const express = require('express');
const dotenv = require('dotenv');
const connectDB = require('./config/db');
const reminderService = require('./services/reminderService');  

dotenv.config();
connectDB();

const app = express();
app.use(express.json());

app.use('/api', require('./routes/api'));

app.get('/', (req, res) => res.send('MediMinder Server Running...'));

const PORT = process.env.PORT || 5050;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
console.log("JWT_SECRET:", process.env.JWT_SECRET);

