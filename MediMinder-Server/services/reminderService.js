const cron = require('node-cron');
const Medication = require('../models/medicationModel');
const Patient = require('../models/patientModel');
const patientService = require('./patientService');
const { activateDueMedications } = require('../controllers/espController');
const caregiverService = require('./caregiverService');
const User = require('../models/userModel');
const medicationLogService = require('../services/medicationLogService');



// const sendMedicationReminders = async () => {
//   try {
//       const currentTime = new Date();
//       const currentHourMinute = `${currentTime.getHours().toString().padStart(2, '0')}:${currentTime.getMinutes().toString().padStart(2, '0')}`;
//       const currentDay = currentTime.toLocaleDateString('en-US', { weekday: 'long' }); 

//       console.log(`🔎 Checking for medication reminders at: ${currentHourMinute} and ${currentDay}`);

//       // Find all medications that should be taken at this time
//       const medications = await Medication.find({
//           "times.time": currentHourMinute,
//           days: currentDay
//         });

//         if (!medications){
//           console.log("medications", medications);}

//       if (!medications || !Array.isArray(medications)) {
//            console.log("⏩ No valid medications found for this time, skipping reminders.");
//            return;
//       }
//       for (const medication of medications) { 
//           //דוסי שימי לב לשורה הזאת -!! אל תשני אותה כי זה מה שלא היה טוב
//           const patient = await Patient.findById(medication.patientId);
//           if (!patient) {
//               console.warn(`⚠️ No patient found for user ${patient.userId}`);
//               continue;
//             }
          
//           console.log(`🔔 Sending reminder to patient ${patient.userId} for medication: ${medication.name}`);
//           await patientService.sendPatientReminder(patient.userId, medication._id, currentHourMinute );  


//           // שליחת תזכורות לכל המטפלים
//           const caregiversId = await patientService.getCaregiversForPatient(patient._id);
//           if (caregiversId && caregiversId.length > 0) {
//             await Promise.all(
//               caregiversId.map(caregiver =>
//                 caregiverService.sendCaregiverReminder(
//                   caregiver,
//                   patient.userId,
//                   medication
//                 )
//               )
//             );
//             console.log(`📣 Reminder also sent to ${caregiversId.length} caregiver(s)`);
//           } else {
//             console.log(`ℹ️ No caregivers found for patient ${patient._id}`);
//           }
//           await activateDueMedications(patient._id);

//       }
//   } catch (error) {
//       console.error('❌ Error sending medication reminders:', error);
//   }
// };

const sendMedicationReminders = async () => {
  try {
    const currentTime = new Date();
    const currentHourMinute = `${currentTime.getHours().toString().padStart(2, '0')}:${currentTime.getMinutes().toString().padStart(2, '0')}`;
    const currentDay = currentTime.toLocaleDateString('en-US', { weekday: 'long' });

    console.log(`🔎 Checking for medication reminders at: ${currentHourMinute} and ${currentDay}`);

      // Find all medications that should be taken at this time
    const medications = await Medication.find({
      "times.time": currentHourMinute,
      days: currentDay
    });

    if (!Array.isArray(medications) || medications.length === 0) {
      console.log("⏩ No valid medications found for this time, skipping reminders.");
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
        console.warn(`⚠️ No patient found for ID ${patientId}`);
        continue;
      }

      const user = await User.findById(patient.userId);
      if (!user) {
        console.warn(`⚠️ No user found for patient ${patient._id}`);
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
  console.log(`📣 Reminder also sent to ${caregiversId.length} caregiver(s)`);
} else {
  console.log(`ℹ️ No caregivers found for patient ${patient._id}`);
}
      await activateDueMedications(patient._id);
    }
  } catch (error) {
    console.error('❌ Error sending medication reminders:', error);
  }
};

//אני לא חושבת שזה רלוונטי לך רייעות אל תראי 

// const sendFollowUpReminders = async () => {
//   try {
//     const currentTime = new Date();
//     currentTime.setMinutes(currentTime.getMinutes() - 10); // בדיקה 10 דקות אחורה
//     const timeToCheck = `${currentTime.getHours().toString().padStart(2, '0')}:${currentTime.getMinutes().toString().padStart(2, '0')}`;
//     const currentDay = currentTime.toLocaleDateString('en-US', { weekday: 'long' });
//     const todayDate = currentTime.toISOString().split('T')[0];

//     const medications = await Medication.find({
//       "times.time": timeToCheck,
//       days: currentDay
//     });

//     if (!Array.isArray(medications) || medications.length === 0) return;

//     for (const med of medications) {
//       const logExists = await medicationLogService.checkExistingLog({
//         medicationId: med._id,
//         patientId: med.patientId,
//         date: todayDate,
//         time: timeToCheck
//       });

//       if (!logExists) {
//         const patient = await Patient.findById(med.patientId);
//         if (!patient) continue;

//         const user = await User.findById(patient.userId);
//         if (!user) continue;

//         const caregivers = await patientService.getCaregiversForPatient(patient._id);
//         if (caregivers && caregivers.length > 0) {
//           await Promise.all(
//             caregivers.map(caregiver =>
//               caregiverService.sendCaregiverReminder(
//                 caregiver,
//                 user._id,
//                 [med] 
//               )
//             )
//           );
//           console.log(`🔁 Follow-up reminder sent to caregivers of ${user.name}`);
//         }
//       }
//     }
//   } catch (error) {
//     console.error('❌ Error in follow-up reminders:', error);
//   }
// };


// Schedule the function to run every minute
cron.schedule('* * * * *', () => {
    sendMedicationReminders();
});

// תזמון תזכורת חוזרת – כל 10 דקות
// cron.schedule('*/10 * * * *', () => {
//   sendFollowUpReminders();
// });

module.exports = { sendMedicationReminders};
