const medicationLogService = require('../services/medicationLogService');

const createMedicationLog = async (req, res) => {
  try {
    const { medicationId, patientId, time, date } = req.body;

    if (!medicationId || !patientId || !time || !date) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const alreadyExists = await medicationLogService.checkExistingLog({ medicationId, patientId, time, date });
    if (alreadyExists) {
      return res.status(409).json({ message: 'Already logged' });
    }

    await medicationLogService.createLog({ medicationId, patientId, time, date });
    res.status(201).json({ message: 'Medication logged successfully' });

  } catch (error) {
    console.error('❌ Error in createMedicationLog:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

const getLogsByPatientAndDate = async (req, res) => {
  try {
    const { patientId, date } = req.params;

    const logs = await medicationLogService.getLogsByPatientAndDate(patientId, date);
    res.status(200).json(logs);
  } catch (err) {
    console.error('❌ Failed to get logs:', err);
    res.status(500).json({ message: 'Failed to fetch logs' });
  }
};

module.exports = { createMedicationLog, getLogsByPatientAndDate };
