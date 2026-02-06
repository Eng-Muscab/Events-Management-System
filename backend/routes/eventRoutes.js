import express from 'express';
const router = express.Router();
import {
    getEvents,
    getEventById,
    getMyEvents,
    createEvent,
    updateEvent,
    deleteEvent,
} from '../controllers/eventController.js';
import { protect, authorize } from '../middleware/authMiddleware.js';

router.route('/')
    .get(getEvents)
    .post(protect, authorize('admin', 'organizer'), createEvent);

router.route('/my')
    .get(protect, authorize('organizer', 'admin'), getMyEvents);

router.route('/:id')
    .get(getEventById)
    .put(protect, authorize('admin', 'organizer'), updateEvent)
    .delete(protect, authorize('admin', 'organizer'), deleteEvent);

export default router;
