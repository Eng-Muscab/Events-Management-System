import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'startup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // A simple drawer layout
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 60, left: 20, bottom: 20),
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: true,
              selectedTileColor: const Color(0xFFE9EAF5),
              onTap: () {
                 Navigator.pop(context);
              },
            ),
             ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Events'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Events if separated
              },
            ),
             ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('My Bookings'),
              onTap: () {
                 Navigator.pop(context);
              },
            ),
             ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                 Navigator.pop(context);
              },
            ),
             const Divider(),
             ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                 Provider.of<AuthProvider>(context, listen: false).logout();
                 Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const StartupScreen()),
                   (route) => false,
                 );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE9EAF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search events',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                   _buildCategoryChip('All', isSelected: true),
                   const SizedBox(width: 10),
                   _buildCategoryChip('Technology'),
                   const SizedBox(width: 10),
                   _buildCategoryChip('Music'),
                   const SizedBox(width: 10),
                   _buildCategoryChip('Sports'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Event List - Hardcoded for UI demo as requested by "build on those screen"
            // In a real app, this would use FutureBuilder with ApiService
            Text('Technology', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              'Tech Summit 2024',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
             const Text(
              'Oct 26, 2024',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Container(
               height: 200,
               width: double.infinity,
               decoration: BoxDecoration(
                 color: Colors.grey[300],
                 borderRadius: BorderRadius.circular(16),
                 image: const DecorationImage(
                   image: NetworkImage('https://images.unsplash.com/photo-1540575467063-178a50c2df87?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80'),
                   fit: BoxFit.cover,
                 ),
               ),
            ),
            const SizedBox(height: 10),
            Chip(label: const Text('San Francisco'), backgroundColor: const Color(0xFFE9EAF5)),

            const SizedBox(height: 30),
             Text('Music', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
             const SizedBox(height: 10),
             const Text(
              'Indie Rock Fest',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
             const Text(
              'Nov 15, 2024',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
             Container(
               height: 200,
               width: double.infinity,
               decoration: BoxDecoration(
                 color: Colors.grey[300],
                 borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                   image: NetworkImage('https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80'),
                   fit: BoxFit.cover,
                 ),
               ),
            ),
             const SizedBox(height: 10),
            Chip(label: const Text('Los Angeles'), backgroundColor: const Color(0xFFE9EAF5)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE9EAF5) : Colors.transparent, // In mockup, 'All' is grey bg
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: Colors.transparent), // Mockup has no visible border for unselected
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
