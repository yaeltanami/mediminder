const cron = require('node-cron');
const Medication = require('../models/medicationModel');
const Patient = require('../models/patientModel');
const patientService = require('./patientService');
const { activateDueMedications } = require('../controllers/espController');
const caregiverService = require('./caregiverService');
const User = require('../models/userModel');
const medicationLogService = require('../services/medicationLogService');



const sendMedicationReminders = async () => {
  try {
    const currentTime = new Date();
    const currentHourMinute = `${currentTime.getHours().toString().padStart(2, '0')}:${currentTime.getMinutes().toString().padStart(2, '0')}`;
    const currentDay = currentTime.toLocaleDateString('en-US', { weekday: 'long' });


      // Find all medications that should be taken at this time
    const medications = await Medication.find({
      "times.time": currentHourMinute,
      days: currentDay
    });

    if (!Array.isArray(medications) || medications.length === 0) {
      console.log("No valid medications found for this time, skipping reminders.");
      return;
    }

    // קיבוץ התרופות לפי patientId
    const medsByPatient = {};
    for (const med of medications) {
      if (!medsByPatient[med.patientId]) {
        medsByPatient[med.patientId] = [];
      }
      medsByPatient[med.patientId].push(med);
    }

    // שליחה לכל מטופל
    for (const patientId of Object.keys(medsByPatient)) {
      const patient = await Patient.findById(patientId);
      if (!patient) {
        console.warn(`No patient found for ID ${patientId}`);
        continue;
      }

      const user = await User.findById(patient.userId);
      if (!user) {
        console.warn(`No user found for patient ${patient._id}`);
        continue;
      }

      const medicationsForPatient = medsByPatient[patientId];
      await patientService.sendPatientReminder(user, medicationsForPatient, currentHourMinute);

// שליחת תזכורות לכל המטפלים
const caregiversId = await patientService.getCaregiversForPatient(patient._id);
if (caregiversId && caregiversId.length > 0) {
  await Promise.all(
    caregiversId.map(caregiver =>
      caregiverService.sendCaregiverReminder(
        caregiver,
        patient.userId,
        medicationsForPatient 
      )
    )
  );
  console.log(`Reminder also sent to ${caregiversId.length} caregiver(s)`);
} else {
  console.log(`ℹNo caregivers found for patient ${patient._id}`);
}
      await activateDueMedications(patient._id);
    }
  } catch (error) {
    console.error('Error sending medication reminders:', error);
  }
};


module.exports = { sendMedicationReminders};
