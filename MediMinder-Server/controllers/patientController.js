const patientService = require('../services/patientService');
const Patient = require('../models/patientModel');
const User = require('../models/userModel');

const jwt = require('jsonwebtoken');


/**
 * בקר לרישום מטופל חדש
 */
const registerPatient = async (req, res) => {
    try {
        console.log("try to register");
        const { name, email, password, birthDate, caregivers } = req.body;

        if (!name || !email || !password || !birthDate) {
            return res.status(400).json({ message: 'All fields are required' });
        }
        console.log("all fiels good");

        const { user, patient, token } = await patientService.registerPatient({ name, email, password, birthDate, caregivers });
        res.status(201).json({ user, patient, token });

    } catch (error) {
                console.log("do not work4");

        res.status(400).json({ message: error.message });
    }
};

/**
 * Controller to get the list of caregiver IDs for a specific patient.
 */
const getCaregiversForPatient = async (req, res) => {
    try {
        const { patientId } = req.params;
        const caregiverIds = await patientService.getCaregiversForPatient(patientId);
        res.status(200).json(caregiverIds);
    } catch (error) {
        res.status(404).json({ message: error.message });
    }
};
const getPatientByUserId = async (req, res) => {
  try {
    const { userId } = req.params;
    const patient = await patientService.findByUserId(userId);
    if (!patient) {
      return res.status(404).json({ message: 'Patient not found' });
    }
    res.json(patient);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getPatientByEmail = async (req, res) => {
    try {
      const { email } = req.query;
      const patient = await patientService.getPatientByEmail(email);
      res.json(patient);
    } catch (err) {
      res.status(404).json({ error: err.message });
    }
  };


  const getUserByPatientId = async (req, res) => {
    console.log("trying to get user by patient id");
  try {
    const { patientId } = req.params;

    // שלב 1 – מציאת המטופל לפי ה־ID
    const patient = await Patient.findById(patientId);
    if (!patient) {
      return res.status(404).json({ message: 'Patient not found' });
    }

    // שלב 2 – מציאת היוזר לפי ה־userId שנמצא במטופל
    const user = await User.findById(patient.userId).select('name email _id'); // שדות רלוונטיים בלבד

    if (!user) {
      return res.status(404).json({ message: 'User not found for patient' });
    }

    // שלב 3 – מחזירים את פרטי היוזר
    res.json(user);

  } catch (error) {
    console.error('❌ Error in getUserByPatientId:', error);
    res.status(500).json({ message: 'Server error' });
  }
};


module.exports = { registerPatient, getPatientByUserId, getPatientByEmail, getUserByPatientId };
