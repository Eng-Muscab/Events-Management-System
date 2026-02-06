import mongoose from 'mongoose';

// Creating menu Scheme table 
const menuSchema = mongoose.Schema(
    {
        name: {
            type: String,
            required: true,
        },
        route: {
            type: String,
            required: true,
        },
        icon: {
            type: String,
            default: 'menu',
        },
        rolesAllowed: {
            type: [String],
            enum: ['admin', 'organizer', 'user'],
            default: ['user'],
        },
    },
    {
        timestamps: true,
    }
);

const Menu = mongoose.model('Menu', menuSchema);

export default Menu;
