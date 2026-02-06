import Registration from '../models/Registration.js';
import Event from '../models/Event.js';
import User from '../models/User.js';

// @desc    Register for an event
// @route   POST /api/registrations
// @access  Private
const registerForEvent = async (req, res, next) => {
    try {
        const { event, eventId } = req.body;
        const targetId = event || eventId;

        // 1. Role Check: Only 'user' role can register
        if (req.user.role !== 'user') {
            res.status(403);
            throw new Error('Only regular users can register for events');
        }

        const eventDoc = await Event.findById(targetId);
        if (!eventDoc) {
            res.status(404);
            throw new Error('Event not found');
        }

        // 2. Duplicate Check: Check if already registered
        const existingRegistration = await Registration.findOne({
            user: req.user._id,
            event: targetId,
        });

        if (existingRegistration) {
            res.status(400);
            throw new Error('You are already registered for this event');
        }

        // 3. Capacity & Seats Check
        const seats = Number(req.body.seats) || 1;
        if (seats <= 0) {
            res.status(400);
            throw new Error('Number of seats must be at least 1');
        }

        const allRegistrations = await Registration.find({ event: targetId });
        const registrationCount = allRegistrations.reduce((sum, reg) => sum + (reg.seats || 1), 0);

        if (registrationCount + seats > eventDoc.capacity) {
            res.status(400);
            const remaining = eventDoc.capacity - registrationCount;
            throw new Error(`Only ${remaining} seats remaining for this event`);
        }

        const totalAmount = (eventDoc.price || 0) * seats;

        const registration = await Registration.create({
            user: req.user._id,
            event: targetId,
            seats,
            amount: totalAmount,
            paymentStatus: totalAmount === 0 ? 'paid' : 'pending',
            attendeeDetails: {
                name: req.body.name || req.user.name,
                email: req.body.email || req.user.email,
                phone: req.body.phone || '',
            },
        });

        res.status(201).json(registration);
    } catch (error) {
        next(error);
    }
};

// @desc    Get participants for an event (Organizer/Admin only)
// @route   GET /api/registrations/event/:eventId
// @access  Private/Organizer/Admin
const getEventParticipants = async (req, res, next) => {
    try {
        const { eventId } = req.params;
        const { search } = req.query;

        const event = await Event.findById(eventId);
        if (!event) {
            res.status(404);
            throw new Error('Event not found');
        }

        // Check ownership unless admin
        if (event.organizer.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
            res.status(403);
            throw new Error('Not authorized to view participants for this event');
        }

        let query = { event: eventId };

        const registrations = await Registration.find(query)
            .populate('user', 'name email')
            .lean();

        // Apply search filtering in memory for nested attendeeDetails/user info
        let filtered = registrations;
        if (search) {
            const searchLower = search.toLowerCase();
            filtered = registrations.filter(reg => {
                const nameMatch = reg.attendeeDetails?.name?.toLowerCase().includes(searchLower) ||
                    reg.user?.name?.toLowerCase().includes(searchLower);
                const phoneMatch = reg.attendeeDetails?.phone?.includes(search);
                return nameMatch || phoneMatch;
            });
        }

        res.json(filtered);
    } catch (error) {
        next(error);
    }
};

// @desc    Get my registrations
// @route   GET /api/registrations/my
// @access  Private
const getMyRegistrations = async (req, res, next) => {
    try {
        const registrations = await Registration.find({ user: req.user._id }).populate({
            path: 'event',
            populate: { path: 'organizer', select: 'name email' }
        });
        res.json(registrations);
    } catch (error) {
        next(error);
    }
};

// @desc    Update payment status (Simulate payment)
// @route   PUT /api/registrations/:id/pay
// @access  Private
const updatePaymentStatus = async (req, res, next) => {
    try {
        const registration = await Registration.findById(req.params.id);

        if (registration) {
            if (registration.user.toString() !== req.user._id.toString()) {
                res.status(403);
                throw new Error('Not authorized to update this registration');
            }

            registration.paymentStatus = 'paid';
            const updatedRegistration = await registration.save();
            res.json(updatedRegistration);
        } else {
            res.status(404);
            throw new Error('Registration not found');
        }
    } catch (error) {
        next(error);
    }
};

// @desc    Get all registrations for organizer's events
// @route   GET /api/registrations/organizer
// @access  Private/Organizer
const getOrganizerRegistrations = async (req, res, next) => {
    try {
        const { search } = req.query;

        // 1. Find all events by this organizer
        const organizerEvents = await Event.find({ organizer: req.user._id }).select('_id');
        const eventIds = organizerEvents.map(e => e._id);

        // 2. Find all registrations for these events
        const registrations = await Registration.find({ event: { $in: eventIds } })
            .populate('event', 'title date location price')
            .populate('user', 'name email')
            .sort({ createdAt: -1 })
            .lean();

        // 3. Filter by search if provided
        let filtered = registrations;
        if (search) {
            const searchLower = search.toLowerCase();
            filtered = registrations.filter(reg => {
                const nameMatch = reg.attendeeDetails?.name?.toLowerCase().includes(searchLower) ||
                    reg.user?.name?.toLowerCase().includes(searchLower);
                const phoneMatch = reg.attendeeDetails?.phone?.includes(search);
                const eventMatch = reg.event?.title?.toLowerCase().includes(searchLower);
                return nameMatch || phoneMatch || eventMatch;
            });
        }

        res.json(filtered);
    } catch (error) {
        next(error);
    }
};

// @desc    Get all registrations
// @route   GET /api/registrations
// @access  Private/Admin
const getAllRegistrations = async (req, res, next) => {
    try {
        const registrations = await Registration.find({})
            .populate('event')
            .populate('user', 'name email');
        res.json(registrations);
    } catch (error) {
        next(error);
    }
};

export {
    registerForEvent,
    getMyRegistrations,
    getAllRegistrations,
    getEventParticipants,
    updatePaymentStatus,
    getOrganizerRegistrations
};
