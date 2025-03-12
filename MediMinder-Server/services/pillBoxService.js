const PillBox = require('../models/pillBoxModel');

/**
 * פונקציה ליצירת קופסה חכמה עבור מטופל.
 * בודקת אם קיימת קופסה למטופל, ואם לא – יוצרת אחת חדשה עם 5 תאים ריקים.
 *
 * @param {string} patientId - מזהה המטופל.
 * @returns {Promise<object>} - מחזירה את הקופסה החדשה שנוצרה.
 */
const createPillBox = async (patientId) => {
    // בדיקה האם יש כבר קופסה קיימת למטופל
    const existingPillBox = await PillBox.findOne({ patientId });
    if (existingPillBox) {
        throw new Error("PillBox already exists for this patient.");
    }

    // יצירת רשימה של 5 תאים ריקים
    const slots = [];
    for (let i = 1; i <= 5; i++) {
        slots.push({ slotNumber: i, status: 'empty', medication: null });
    }

    // יצירת הקופסה ושמירה במסד הנתונים
    const pillBox = new PillBox({ patientId, slots });
    await pillBox.save();

    console.log(`📦 קופסה חכמה נוצרה למטופל ${patientId}`);

    return pillBox;
};


/**
 * הקצאת תרופה לאחד מחמשת התאים בקופסה החכמה.
 *
 * @param {string} patientId - מזהה המטופל.
 * @param {string} medicationId - מזהה התרופה.
 * @param {number} slotNumber - מספר התא (1-5).
 * @returns {Promise<object>} - מחזיר את הקופסה המעודכנת.
 */
const assignMedicationToSlot = async (patientId, medicationId, slotNumber) => {
    // בדיקה שהמספר תקין
    if (slotNumber < 1 || slotNumber > 5) {
        throw new Error("Invalid slot number. Must be between 1 and 5.");
    }

    // חיפוש הקופסה של המטופל
    const pillBox = await PillBox.findOne({ patientId });
    if (!pillBox) {
        throw new Error("PillBox not found for this patient.");
    }

    // בדיקת קיום התרופה
    const medication = await Medication.findById(medicationId);
    if (!medication) {
        throw new Error("Medication not found.");
    }

    // מציאת התא הרלוונטי בקופסה
    const slot = pillBox.slots.find(s => s.slotNumber === slotNumber);
    if (!slot) {
        throw new Error("Invalid slot assignment.");
    }

    // בדיקה שהתא לא תפוס כבר
    if (slot.status === 'filled') {
        throw new Error(`Slot ${slotNumber} is already occupied.`);
    }

    // עדכון התא עם התרופה
    slot.medication = medicationId;
    slot.status = 'filled';
    medication.slotNumber = slotNumber;

    // שמירת העדכונים
    await pillBox.save();
    await medication.save();

    console.log(`💊 התרופה "${medication.name}" הוקצתה לתא מספר ${slotNumber}`);

    return pillBox;
};

/**
 * מחפש תא פנוי בקופסה החכמה של המטופל.
 * מחזיר את מספר התא הפנוי הראשון שנמצא.
 *
 * @param {string} patientId - מזהה המטופל.
 * @returns {number | null} - מספר התא הפנוי או `null` אם אין מקום פנוי.
 */
const findEmptySlot = async (patientId) => {
    const pillBox = await PillBox.findOne({ patientId });

    if (!pillBox) {
        throw new Error("PillBox not found for this patient.");
    }

    // חיפוש התא הראשון שעדיין ריק
    const emptySlot = pillBox.slots.find(slot => slot.status === 'empty');

    return emptySlot ? emptySlot.slotNumber : null;
};

/**
 * מקבל מטופל ותרופה, ומכניס את התרופה לתא פנוי בקופסה.
 * אם אין מקום פנוי, מחזיר שגיאה.
 *
 * @param {string} patientId - מזהה המטופל.
 * @param {string} medicationId - מזהה התרופה.
 * @returns {Promise<object>} - מחזיר את הקופסה המעודכנת.
 */
const assignMedicationToAvailableSlot = async (patientId, medicationId) => {
    // חיפוש תא פנוי
    const slotNumber = await findEmptySlot(patientId);
    if (!slotNumber) {
        throw new Error("No available slots in the pillbox.");
    }

    // שימוש בפונקציה שכבר כתבנו להקצאת התרופה לתא שנמצא פנוי
    const updatedPillBox = await assignMedicationToSlot(patientId, medicationId, slotNumber);

    console.log(`💊 התרופה הוקצתה אוטומטית לתא ${slotNumber}`);

    return { updatedPillBox, slotNumber };
};

module.exports = { createPillBox, assignMedicationToSlot, assignMedicationToAvailableSlot };
