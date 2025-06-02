const MedicationLog = require('../models/medicationLogModel');

const checkExistingLog = async ({ medicationId, patientId, time, date }) => {
  return await MedicationLog.findOne({ medicationId, patientId, time, date });
};

const createLog = async ({ medicationId, patientId, time, date }) => {
  const log = new MedicationLog({ medicationId, patientId, time, date });
  await log.save();
};

/**
 * מחזיר את כל הלוגים של מטופל בתאריך מסוים (בפורמט YYYY-MM-DD)
 * 
 * @param {string} patientId - מזהה המטופל
 * @param {string} date - תאריך בפורמט YYYY-MM-DD
 * @returns {Promise<Array>} - מערך של לוגים
 */
const getLogsByPatientAndDate = async (patientId, date) => {
  try {
    return await MedicationLog.find({
      patientId,
      date,
    });
  } catch (err) {
    console.error('❌ שגיאה בשליפת הלוגים:', err);
    throw err;
  }
};
module.exports = { checkExistingLog, createLog, getLogsByPatientAndDate };
