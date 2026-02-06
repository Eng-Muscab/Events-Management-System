import Menu from '../models/Menu.js';

const getMenus = async (req, res, next) => {
    try {
        const role = req.user.role;
        // Find menus where the rolesAllowed array contains the user's role
        const menus = await Menu.find({ rolesAllowed: role });
        res.json(menus);
    } catch (error) {
        next(error);
    }
};


const createMenu = async (req, res, next) => {
    try {
        const { name, route, icon, rolesAllowed } = req.body;

        const menu = await Menu.create({
            name,
            route,
            icon,
            rolesAllowed,
        });

        res.status(201).json(menu);
    } catch (error) {
        next(error);
    }
};

export { getMenus, createMenu };