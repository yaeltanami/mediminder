const Caregiver = require('../models/caregiverModel');

exports.createCaregiver = async (req, res) => {
    try {
        const { userId, patients, relation, experienceYears } = req.body;

        const caregiver = new Caregiver({
            userId,
            patients: patients || [],
            relation,
            experienceYears
        });

        await caregiver.save();
        res.status(201).json({ message: "Caregiver profile created", caregiver });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.getCaregivers = async (req, res) => {
    try {
        const caregivers = await Caregiver.find().populate('userId patients');
        res.status(200).json(caregivers);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};
