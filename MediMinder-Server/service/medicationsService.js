const Medication = require('../models/medicationModel');
const Patient = require('../models/patientModel');


// הוספת תרופה למטופל אחד
async function addMedication(patientId, name, dose, times, slotNumber) {
    try {
        const newMedication = new Medication({
            patientId,
            name,
            dose,
            times,
            slotNumber
        });
        const savedMedication = await newMedication.save();  // שומר את התרופה במסד הנתונים
//הוספת המזהה של התרופה למערך התרופות 
        await Patient.findByIdAndUpdate(patientId, {
            $push: { medications: savedMedication._id },
          });
        return savedMedication; 
    } catch (error) {
        console.error('Error adding medication:', error);
        throw error;
    }
}

async function getMedicationsForPatient(patientId) {
    try {
        const medications = await Medication.find({ patientId });
        return medications;
    } catch (error) {
        console.error('Error getting medications:', error);
        throw error;
    }
}

module.exports = {
    addMedication,getMedicationsForPatient}
