import mongoose from 'mongoose';
import dotenv from 'dotenv';
import bcrypt from 'bcryptjs';
import connectDB from './config/db.js';
import User from './models/User.js';
import Category from './models/Category.js';
import Event from './models/Event.js';
import Registration from './models/Registration.js';
import Payment from './models/Payment.js';
import Menu from './models/Menu.js';

dotenv.config();

connectDB();

const importData = async () => {
    try {
        // Clear existing data
        await OrderClear();

        console.log('Data Cleared...');

        // 1. Create Users
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash('123456', salt);

        const users = await User.insertMany([
            {
                name: 'Admin User',
                email: 'admin@example.com',
                password: hashedPassword,
                role: 'admin',
            },
            {
                name: 'Organizer User',
                email: 'organizer@example.com',
                password: hashedPassword,
                role: 'organizer',
            },
            {
                name: 'Regular User',
                email: 'user@example.com',
                password: hashedPassword,
                role: 'user',
            },
        ]);

        const adminUser = users[0]._id;
        const organizerUser = users[1]._id;
        const regularUser = users[2]._id;

        console.log('Users Imported...');

        // 2. Create Categories
        const categories = await Category.insertMany([
            { name: 'Technology', description: 'Tech events and conferences' },
            { name: 'Music', description: 'Live music and concerts' },
            { name: 'Sports', description: 'Sports meets and competitions' },
            { name: 'Business', description: 'Business networking and seminars' },
            { name: 'Art', description: 'Art exhibitions and workshops' },
        ]);

        console.log('Categories Imported...');

        // 3. Create Events
        const events = await Event.insertMany([
            {
                title: 'Tech Summit 2024',
                description: 'The biggest tech conference of the year featuring top speakers.',
                date: new Date('2024-10-26'),
                time: '09:00 AM',
                location: 'San Francisco, CA',
                capacity: 500,
                category: categories[0]._id, // Technology
                organizer: organizerUser,
                price: 150,
            },
            {
                title: 'Indie Rock Fest',
                description: 'A weekend of amazing indie rock music.',
                date: new Date('2024-11-15'),
                time: '04:00 PM',
                location: 'Los Angeles, CA',
                capacity: 2000,
                category: categories[1]._id, // Music
                organizer: organizerUser,
                price: 45,
            },
            {
                title: 'Marathon Challenge',
                description: 'Annual city marathon for all ages.',
                date: new Date('2024-12-05'),
                time: '06:00 AM',
                location: 'New York, NY',
                capacity: 1000,
                category: categories[2]._id, // Sports
                organizer: organizerUser,
                price: 25,
            },
            {
                title: 'Startup Networking Night',
                description: 'Meet investors and fellow entrepreneurs.',
                date: new Date('2024-09-20'),
                time: '07:00 PM',
                location: 'Austin, TX',
                capacity: 100,
                category: categories[3]._id, // Business
                organizer: organizerUser,
            }
        ]);

        console.log('Events Imported...');

        // 4. Create Registrations
        const registrations = await Registration.insertMany([
            {
                user: regularUser,
                event: events[0]._id, // Tech Summit
                status: 'registered',
            },
            {
                user: regularUser,
                event: events[1]._id, // Indie Rock Fest
                status: 'registered',
            },
            {
                user: regularUser,
                event: events[2]._id, // Marathon
                status: 'cancelled',
            }
        ]);

        console.log('Registrations Imported...');

        // 5. Create Payments
        await Payment.insertMany([
            {
                registration: registrations[0]._id,
                amount: 150.00,
                paymentMethod: 'Credit Card',
                paymentStatus: 'completed',
            },
            {
                registration: registrations[1]._id,
                amount: 75.50,
                paymentMethod: 'PayPal',
                paymentStatus: 'completed',
            }
        ]);

        console.log('Payments Imported...');

        // 6. Create Menus
        const menus = [
            {
                name: 'Dashboard',
                route: '/dashboard',
                icon: 'dashboard',
                rolesAllowed: ['admin', 'organizer', 'user'],
            },
            {
                name: 'Manage Users',
                route: '/users',
                icon: 'people',
                rolesAllowed: ['admin'],
            },
            {
                name: 'Manage Events',
                route: '/events',
                icon: 'event',
                rolesAllowed: ['admin', 'organizer'],
            },
            {
                name: 'My Events',
                route: '/my-events',
                icon: 'event_available',
                rolesAllowed: ['organizer'],
            },
            {
                name: 'My Registrations',
                route: '/registrations',
                icon: 'list',
                rolesAllowed: ['user'],
            },
            // Profile route isn't strictly needed in DB as we made it static/hybrid, but good to have if we want to control it via DB
        ];

        await Menu.insertMany(menus);
        console.log('Menus Imported...');

        console.log('ALL DATA IMPORTED SUCCESS!');
        process.exit();
    } catch (error) {
        console.error(`${error}`);
        process.exit(1);
    }
};

const destroyData = async () => {
    try {
        await OrderClear();

        console.log('Data Destroyed!');
        process.exit();
    } catch (error) {
        console.error(`${error}`);
        process.exit(1);
    }
};

const OrderClear = async () => {
    await Payment.deleteMany();
    await Registration.deleteMany();
    await Event.deleteMany();
    await Category.deleteMany();
    await User.deleteMany();
    await Menu.deleteMany();
}

if (process.argv[2] === '-d') {
    destroyData();
} else {
    importData();
}
