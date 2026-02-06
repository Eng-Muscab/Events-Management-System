import Event from '../models/Event.js';
import Registration from '../models/Registration.js';

// @desc    Fetch all events
// @route   GET /api/events
// @access  Public
const getEvents = async (req, res, next) => {
    try {
        const now = new Date();
        // Fetch upcoming events
        const upcomingEvents = await Event.find({ date: { $gte: now } })
            .populate('category', 'name')
            .populate('organizer', 'name email')
            .sort({ date: 1 }) // Nearest first
            .lean();

        // Fetch past events
        const pastEvents = await Event.find({ date: { $lt: now } })
            .populate('category', 'name')
            .populate('organizer', 'name email')
            .sort({ date: -1 }) // Most recent first
            .lean();

        const allEvents = [...upcomingEvents, ...pastEvents];

        // Add registration count to each event
        const eventsWithCount = await Promise.all(allEvents.map(async (event) => {
            const registrations = await Registration.find({ event: event._id });
            const registrationCount = registrations.reduce((sum, reg) => sum + (reg.seats || 1), 0);
            return { ...event, registrationCount };
        }));

        res.json(eventsWithCount);
    } catch (error) {
        next(error);
    }
};

// @desc    Fetch single event
// @route   GET /api/events/:id
// @access  Public
const getEventById = async (req, res, next) => {
    try {
        const event = await Event.findById(req.params.id).populate('category', 'name').populate('organizer', 'name email').lean();

        if (event) {
            const registrations = await Registration.find({ event: event._id });
            const registrationCount = registrations.reduce((sum, reg) => sum + (reg.seats || 1), 0);
            res.json({ ...event, registrationCount });
        } else {
            res.status(404);
            throw new Error('Event not found');
        }
    } catch (error) {
        next(error);
    }
};

// @desc    Create an event
// @route   POST /api/events
// @access  Private/Admin/Organizer
const createEvent = async (req, res, next) => {
    try {
        const { title, description, date, time, location, capacity, category } = req.body;

        const event = new Event({
            title,
            description,
            date,
            time,
            location,
            capacity,
            price: req.body.price || 0,
            category,
            organizer: req.user._id,
        });

        const createdEvent = await event.save();
        res.status(201).json(createdEvent);
    } catch (error) {
        next(error);
    }
};

// @desc    Update an event
// @route   PUT /api/events/:id
// @access  Private/Admin/Organizer
const updateEvent = async (req, res, next) => {
    try {
        const event = await Event.findById(req.params.id);

        if (event) {
            // Check ownership unless admin
            if (event.organizer.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
                res.status(403);
                throw new Error('Not authorized to update this event');
            }

            event.title = req.body.title || event.title;
            event.description = req.body.description || event.description;
            event.date = req.body.date || event.date;
            event.time = req.body.time || event.time;
            event.location = req.body.location || event.location;
            event.capacity = req.body.capacity !== undefined ? req.body.capacity : event.capacity;
            event.price = req.body.price !== undefined ? req.body.price : event.price;
            event.category = req.body.category || event.category;

            const updatedEvent = await event.save();
            res.json(updatedEvent);
        } else {
            res.status(404);
            throw new Error('Event not found');
        }
    } catch (error) {
        next(error);
    }
};

// @desc    Delete an event
// @route   DELETE /api/events/:id
// @access  Private/Admin/Organizer
const deleteEvent = async (req, res, next) => {
    try {
        const event = await Event.findById(req.params.id);

        if (event) {
            // Check ownership unless admin
            if (event.organizer.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
                res.status(403);
                throw new Error('Not authorized to delete this event');
            }

            await event.deleteOne();
            res.json({ message: 'Event removed' });
        } else {
            res.status(404);
            throw new Error('Event not found');
        }
    } catch (error) {
        next(error);
    }
};

// @desc    Get my events (Organizer only)
// @route   GET /api/events/my
// @access  Private/Organizer
const getMyEvents = async (req, res, next) => {
    try {
        const events = await Event.find({ organizer: req.user._id })
            .populate('category', 'name')
            .populate('organizer', 'name email')
            .sort({ date: 1 })
            .lean();

        const eventsWithCount = await Promise.all(events.map(async (event) => {
            const registrations = await Registration.find({ event: event._id });
            const registrationCount = registrations.reduce((sum, reg) => sum + (reg.seats || 1), 0);
            return { ...event, registrationCount };
        }));

        res.json(eventsWithCount);
    } catch (error) {
        next(error);
    }
};

export {
    getEvents,
    getEventById,
    getMyEvents,
    createEvent,
    updateEvent,
    deleteEvent,
};
