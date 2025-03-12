const Patient = require('../models/patientModel');

exports.createPatient = async (req, res) => {
    try {
        const { userId, birthDate, caregivers } = req.body;

        const patient = new Patient({
            userId,
            birthDate,
            caregivers: caregivers || [],
            medications: []
        });

        await patient.save();
        res.status(201).json({ message: "Patient profile created", patient });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.getPatients = async (req, res) => {
    try {
        const patients = await Patient.find().populate('userId caregivers medications');
        res.status(200).json(patients);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};
