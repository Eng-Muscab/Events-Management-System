import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/event_provider.dart';
import '../providers/category_provider.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';
import 'event_register_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedCategoryName = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).fetchEvents();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    
    // Filter events based on selection
    final allEvents = eventProvider.events;
    final filteredEvents = _selectedCategoryName == 'All'
        ? allEvents
        : allEvents.where((e) => e.categoryName == _selectedCategoryName).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover Events',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
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
                _buildCategoryChip('All'),
                const SizedBox(width: 10),
                if (categoryProvider.isLoading)
                   const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  ...categoryProvider.categories.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _buildCategoryChip(cat.name),
                    );
                  }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Event List
          if (eventProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (filteredEvents.isEmpty)
             const Center(child: Text("No events found"))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventRegisterScreen(event: event),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.transparent,
                    margin: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(event.categoryName, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                         const SizedBox(height: 10),
                         Text(
                          event.title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                         Text(
                          '${DateFormat('MMM dd, yyyy').format(DateTime.parse(event.date))} • ${event.time}',
                          style: const TextStyle(color: Colors.grey),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(event.location), 
                              backgroundColor: const Color(0xFFE9EAF5),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: event.registrationCount >= event.capacity ? Colors.red[50] : Colors.green[50],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${event.registrationCount}/${event.capacity} Joined',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: event.registrationCount >= event.capacity ? Colors.red[700] : Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategoryName == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryName = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE9EAF5) : Colors.transparent, 
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.3)), // Add border for unselected
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
