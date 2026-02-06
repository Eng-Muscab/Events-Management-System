import express from 'express';
const router = express.Router();
import { registerForEvent, getMyRegistrations, getAllRegistrations, getEventParticipants, updatePaymentStatus, getOrganizerRegistrations } from '../controllers/registrationController.js';
import { protect, authorize } from '../middleware/authMiddleware.js';

// All routes are protected
router.use(protect);

router.post('/', registerForEvent);
router.get('/', authorize('admin'), getAllRegistrations);
router.get('/my', getMyRegistrations);
router.get('/organizer', authorize('organizer', 'admin'), getOrganizerRegistrations);
router.get('/event/:eventId', authorize('organizer', 'admin'), getEventParticipants);
router.put('/:id/pay', updatePaymentStatus);

export default router;
