import express from 'express';
const router = express.Router();
import { getMenus, createMenu } from '../controllers/menuController.js';
import { protect, authorize } from '../middleware/authMiddleware.js';

router.route('/')
    .get(protect, getMenus)
    .post(protect, authorize('admin'), createMenu);

export default router;
