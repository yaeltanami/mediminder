const PillBox = require('../models/pillBoxModel');
const Medication = require('../models/medicationModel');

exports.assignMedicationToSlot = async (req, res) => {
    try {
        const { patientId, medicationId, slotNumber } = req.body;

        if (slotNumber < 1 || slotNumber > 5) {
            return res.status(400).json({ message: "Invalid slot number. Must be between 1 and 5." });
        }

        const pillBox = await PillBox.findOne({ patientId });
        if (!pillBox) {
            return res.status(404).json({ message: "PillBox not found for this patient." });
        }

        const medication = await Medication.findById(medicationId);
        if (!medication) {
            return res.status(404).json({ message: "Medication not found." });
        }

        // מציאת התא הרלוונטי והכנסת התרופה
        const slot = pillBox.slots.find(s => s.slotNumber === slotNumber);
        if (!slot) {
            return res.status(400).json({ message: "Invalid slot assignment." });
        }

        slot.medication = medicationId;
        slot.status = 'filled';
        medication.slotNumber = slotNumber;

        await pillBox.save();
        await medication.save();

        console.log(`💊 התרופה "${medication.name}" הוקצתה לתא מספר ${slotNumber}`);

        res.status(200).json({ message: `Medication assigned to slot ${slotNumber}`, pillBox });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};
