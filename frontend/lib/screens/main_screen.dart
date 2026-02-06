import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/auth_provider.dart';
import '../models/menu_item.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';
import 'events_screen.dart';
import 'bookings_screen.dart';
import 'profile_screen.dart';
import 'startup_screen.dart';
import 'manage_users_screen.dart';
import 'organizer_events_screen.dart';
import 'manage_events_screen.dart';
import 'manage_categories_screen.dart';
import 'organizer_bookings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).fetchMenus();
    });
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'dashboard':
        return Icons.dashboard;
      case 'people':
        return Icons.people;
      case 'event':
        return Icons.event;
      case 'event_available':
        return Icons.event_available;
      case 'list':
        return Icons.list;
      case 'list_alt':
        return Icons.list_alt;
      case 'person_outline':
        return Icons.person_outline;
      case 'manage_accounts': // Add manual mappings if backend sends others
        return Icons.manage_accounts;
      default:
        return Icons.circle; // Default icon
    }
  }

  Widget _getPageForRoute(String route) {
    switch (route) {
      case '/dashboard':
        return const DashboardScreen();
      case '/events':
         // If admin, show ManageEvents, if organizer (or public via dashboard), handle accordingly.
         // Based on seeder, '/events' is for 'Manage Events' (Admin/Organizer).
        return const ManageEventsScreen(); 
      case '/my-events':
        return const OrganizerEventsScreen();
      case '/registrations':
        return const BookingsScreen();
      case '/users':
        return const ManageUsersScreen(); 
      case '/categories':
        return const ManageCategoriesScreen();
      case '/organizer-bookings':
        return const OrganizerBookingsScreen();
      case '/profile':
        return const ProfileScreen();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;
    List<MenuItem> menus = List.from(menuProvider.menus);
    
    if (user?.role == 'admin') {
      menus = [
        MenuItem(id: 'dash', name: 'Dashboard', route: '/dashboard', icon: 'dashboard'),
        MenuItem(id: 'users', name: 'Manage Users', route: '/users', icon: 'people'),
        MenuItem(id: 'events', name: 'Manage Events', route: '/events', icon: 'event'),
        MenuItem(id: 'profile', name: 'Profile', route: '/profile', icon: 'person_outline'),
      ];
    } else if (user?.role == 'participator' || user?.role == 'user') {
      menus = [
        MenuItem(id: 'home', name: 'Home', route: '/dashboard', icon: 'dashboard'),
        MenuItem(id: 'events', name: 'Events', route: '/dashboard', icon: 'event'),
        MenuItem(id: 'bookings', name: 'My Bookings', route: '/registrations', icon: 'list_alt'),
        MenuItem(id: 'profile', name: 'Profile', route: '/profile', icon: 'person_outline'),
      ];
    } else if (user?.role == 'organizer') {
      menus = [
        MenuItem(id: 'dash', name: 'Dashboard', route: '/dashboard', icon: 'dashboard'),
        MenuItem(id: 'my-events', name: 'My Events', route: '/my-events', icon: 'event'),
        MenuItem(id: 'bookings', name: 'Booked Users', route: '/organizer-bookings', icon: 'list_alt'),
        MenuItem(id: 'profile', name: 'Profile', route: '/profile', icon: 'person_outline'),
      ];
    } else {
      // Add Profile for non-admins if not present
      if (menus.isNotEmpty && !menus.any((m) => m.route == '/profile')) {
        menus.add(MenuItem(
          id: 'profile_static',
          name: 'Profile',
          route: '/profile',
          icon: 'person_outline',
        ));
      }
    }

    if (menuProvider.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Always ensure index is valid if menus change
    if (_selectedIndex >= menus.length) {
      _selectedIndex = 0;
    }

    final currentMenuItem = menus[_selectedIndex];
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Drawer Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'User Name',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user?.email ?? 'user@example.com',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Drawer Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    final menu = menus[index];
                    final isSelected = _selectedIndex == index;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getIconData(menu.icon),
                          color: isSelected ? AppColors.primary : Colors.black87,
                        ),
                        title: Text(
                          menu.name,
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          _onItemTapped(index);
                          Navigator.pop(context);
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              // Logout at bottom
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const StartupScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: _getPageForRoute(currentMenuItem.route),
      bottomNavigationBar: BottomNavigationBar(
        items: menus.map((menu) {
          return BottomNavigationBarItem(
            icon: Icon(_getIconData(menu.icon)),
            label: menu.name,
          );
        }).toList(),
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
