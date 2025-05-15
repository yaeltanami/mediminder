const cron = require('node-cron');
const Medication = require('../models/medicationModel');
const Patient = require('../models/patientModel');
const patientService = require('./patientService');
const { activateDueMedications } = require('../controllers/espController');


/**
 * Sends reminders to patients who need to take medication at the current time.
 */
const sendMedicationReminders = async () => {
    try {
        const currentTime = new Date();
        const currentHourMinute = currentTime.toTimeString().slice(0, 5); // פורמט "HH:MM"

        console.log(`🔎 Checking for medication reminders at: ${currentHourMinute}`);

        // Find all medications that should be taken at this time
        const medications = await Medication.find({ "times.time": currentHourMinute });
        console.log(`🧪 Found ${medications.length} medications to remind`);

        for (const medication of medications) {
            const patient = await Patient.findById(medication.patientId);
            console.log(`🧬 Trying to find patient for medication ${medication.name}, patientId: ${medication.patientId}`);


            if (!patient){
                console.log('❌ Patient not found for this medication');
                continue;
            } 

            console.log(`🔔 Sending reminder to patient ${patient.userId} for medication ${medication.name}`);

            // Call function in patientService to send the reminder
            await patientService.sendPatientReminder(patient.userId, medication._id);
            console.log(`🚨 Calling activateDueMedications for patient._id: ${patient._id}`);

            await activateDueMedications(patient._id);

        }
    } catch (error) {
        console.error('❌ Error sending medication reminders:', error);
    }
};

// Schedule the function to run every minute
cron.schedule('* * * * *', () => {
    sendMedicationReminders();
    console.log("📅 Medication reminder service is running...");
});

module.exports = { sendMedicationReminders };
