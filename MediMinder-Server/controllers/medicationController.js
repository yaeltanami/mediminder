const Medication = require('../models/medicationModel');

exports.addMedication = async (req, res) => {
    try {
        const { patientId, name, dose, times } = req.body;

        const medication = new Medication({
            patientId,
            name,
            dose,
            times
        });

        await medication.save();
        res.status(201).json({ message: "Medication added", medication });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.getMedicationsForPatient = async (req, res) => {
    try {
        const { patientId } = req.params;
        const medications = await Medication.find({ patientId });
        res.status(200).json(medications);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};
