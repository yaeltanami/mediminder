const mongoose = require('mongoose');
const Medication = require('./models/medicationModel');
const Patient = require('./models/patientModel');

const MONGO_URI = 'mongodb://127.0.0.1:27017/MediMinder';

const run = async () => {
  await mongoose.connect(MONGO_URI);
  console.log('Connected to MongoDB');

  // 1. מציאת מטופל קיים
  const patient = await Patient.findOne(); // אם את יודעת את ה-userId, אפשר גם .findOne({ userId: '...' })
  if (!patient) {
    console.error('No patient found in DB');
    process.exit();
  }


  // 2. מחיקת כל התרופות של המטופל
  await Medication.deleteMany({ patientId: patient._id });
  console.log('Deleted existing medications for this patient');

  // 3. יצירת תרופות חדשות
  const newMedications = [
    {
      patientId: patient._id,
      name: 'Advil',
      dose: '1 tablet',
      times: [
        { time: '00:09', pillsCount: 1 },
        { time: '23:58', pillsCount: 1 }
      ],
      days: ['Tuesday'],
      slotNumber: 1
    },
    {
      patientId: patient._id,
      name: 'Paracetamol',
      dose: '1 tablet',
      times: [
        { time: '23:57', pillsCount: 1 }
      ],
      days: ['Monday'],
      slotNumber: 2
    }
  ];

  await Medication.insertMany(newMedications);

  await mongoose.disconnect();
  console.log('Disconnected from MongoDB');
};

run();
