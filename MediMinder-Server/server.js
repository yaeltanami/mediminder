const express = require('express');
const dotenv = require('dotenv');
const connectDB = require('./config/db');

dotenv.config();
connectDB();

const app = express();
app.use(express.json());

app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/patients', require('./routes/patientRoutes'));
app.use('/api/caregivers', require('./routes/caregiverRoutes'));
app.use('/api/medications', require('./routes/medicationRoutes'));

app.get('/', (req, res) => res.send('MediMinder Server Running...'));

const PORT = process.env.PORT || 5050;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
