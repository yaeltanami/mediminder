const PillBox = require('../models/pillBoxModel');
const Medication = require('../models/medicationModel');


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

    console.log(`📦 Smart box created for patient ${patientId}`);

    return pillBox;
};


/**
 * מקצה תרופה לתא פנוי בקופסה החכמה של המטופל.
 *
 * @param {string} patientId - מזהה המטופל.
 * @param {string} medicationId - מזהה התרופה.
 * @returns {Promise<object>} - מחזיר את הקופסה המעודכנת ואת מספר התא.
 */
const assignMedicationToAvailableSlot = async (patientId, medicationId) => {
    try {
        const pillBox = await PillBox.findOne({ patientId });

        if (!pillBox) {
            throw new Error("❌ No pillbox found for this patient.");
        }

        // חיפוש התא הפנוי הראשון
        const slot = pillBox.slots.find(s => s.status === 'empty');

        if (!slot) {
            throw new Error("❌ No available slots in the pillbox.");
        }

        // עדכון התא עם התרופה
        slot.medication = medicationId;
        slot.status = 'filled';

        await pillBox.save();

        console.log(`💊 The medication was assigned to slot number ${slot.slotNumber}`);

        return { updatedPillBox: pillBox, slotNumber: slot.slotNumber };
    } catch (error) {
        console.error("❌ Error assigning medication:", error);
        throw error;
    }
};

/**
 * פונקציה להסרת תרופה מהתא בקופסה החכמה.
 * אם התרופה נמצאת בתא כלשהו, התא יהפוך ל"empty".
 *
 * @param {string} patientId - מזהה המטופל.
 * @param {string} medicationId - מזהה התרופה למחיקה.
 * @returns {Promise<object>} - מחזיר את הקופסה המעודכנת.
 */
const removeMedicationFromPillBox = async (patientId, medicationId) => {
    try {
        const pillBox = await PillBox.findOne({ patientId });

        if (!pillBox) {
            console.log("❌ No pillbox found for this patient.");
            return { message: "No pillbox found" };
        }

        // מציאת התא שבו נמצאת התרופה
        const slot = pillBox.slots.find(slot => slot.medication?.toString() === medicationId);
        
        if (!slot) {
            console.log("❌ Medication not found in any slot.");
            return { message: "Medication not found in pillbox" };
        }

        // ניקוי התא
        slot.medication = null;
        slot.status = "empty";

        await pillBox.save();

        console.log(`📦 Slot number ${slot.slotNumber} is now empty`);
        return pillBox;
    } catch (error) {
        console.error("❌ Error removing medication from pillbox:", error);
        throw error;
    }
};


/**
 * Retrieves the pillbox status for a specific patient.
 *
 * @param {string} patientId - The ID of the patient.
 * @returns {Promise<object>} - The pillbox status with slot details.
 */
const getPillBoxStatus = async (patientId) => {
    try {
        // חיפוש קופסת התרופות של המטופל
        const pillBox = await PillBox.findOne({ patientId });

        if (!pillBox) {
            throw new Error("PillBox not found for this patient.");
        }

        // מיפוי התאים עם סטטוס (ריק או שם התרופה)
        const slots = await Promise.all(
            pillBox.slots.map(async (slot) => {
                if (slot.status === 'empty') {
                    return { slotNumber: slot.slotNumber, status: "Empty" };
                } else {
                    const medication = await Medication.findById(slot.medication);
                    return {
                        slotNumber: slot.slotNumber,
                        status: medication ? medication.name : "Unknown Medication"
                    };
                }
            })
        );

        return { patientId, slots };
    } catch (error) {
        console.error("❌ Error retrieving pillbox status:", error);
        throw error;
    }
};



module.exports = { 
    createPillBox,  
    assignMedicationToAvailableSlot,
     removeMedicationFromPillBox,
     getPillBoxStatus
     };
