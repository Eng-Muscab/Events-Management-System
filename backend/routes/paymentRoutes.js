import express from 'express';
const router = express.Router();
import { createPayment } from '../controllers/paymentController.js';
import { protect } from '../middleware/authMiddleware.js';

router.post('/', protect, createPayment);

export default router;
