const mongoose = require('mongoose');
const User = require('./models/userModel');
const Patient = require('./models/patientModel');

const MONGO_URI = 'mongodb://127.0.0.1:27017/MediMinder';

const run = async () => {
  await mongoose.connect(MONGO_URI);
  console.log('Connected to MongoDB');

  // יצירת משתמש חדש
  const user = await User.create({
    name: 'Test Patient',
    email: 'patient@example.com',
    password: '123456', // שימי לב: לא מוצפן!
    role: 'patient'
  });

  // יצירת מטופל חדש עם userId
  const patient = await Patient.create({
    userId: user._id,
    birthDate: new Date('2000-01-01'),
    caregivers: [],
    medications: [],
    pillBox: null
  });


  await mongoose.disconnect();
  console.log('Disconnected from MongoDB');
};

run();
