import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/category.dart';
import '../providers/event_provider.dart';
import '../providers/category_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_widgets.dart';
import 'event_participants_screen.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).fetchEvents();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEventModal({Event? event}) {
    final titleController = TextEditingController(text: event?.title ?? '');
    final descController = TextEditingController(text: event?.description ?? '');
    final locationController = TextEditingController(text: event?.location ?? '');
    final capacityController = TextEditingController(text: event?.capacity.toString() ?? '');
    final priceController = TextEditingController(text: event?.price.toStringAsFixed(0) ?? '0');
    final dateController = TextEditingController(text: event?.date ?? DateTime.now().toIso8601String().split('T')[0]);
    final timeController = TextEditingController(text: event?.time ?? '10:00 AM');
    
    final categories = Provider.of<CategoryProvider>(context, listen: false).categories;
    String? selectedCategoryId;
    
    if (event != null && categories.isNotEmpty) {
      try {
        selectedCategoryId = categories.firstWhere((c) => c.name == event.categoryName).id;
      } catch (e) {
        selectedCategoryId = categories.isNotEmpty ? categories.first.id : null;
      }
    } else if (categories.isNotEmpty) {
      selectedCategoryId = categories.first.id;
    }

    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event == null ? 'Add Event' : 'Edit Event',
                        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(label: 'Event Title', controller: titleController),
                  const SizedBox(height: 16),
                  CustomTextField(label: 'Description', controller: descController),
                  const SizedBox(height: 16),
                  CustomTextField(label: 'Location', controller: locationController),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: CustomTextField(label: 'Date (YYYY-MM-DD)', controller: dateController)),
                      const SizedBox(width: 16),
                      Expanded(child: CustomTextField(label: 'Time', controller: timeController)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: CustomTextField(label: 'Capacity', controller: capacityController, keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(child: CustomTextField(label: 'Price (\$)', controller: priceController, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9EAF5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategoryId,
                            isExpanded: true,
                            items: categories.map((c) {
                              return DropdownMenuItem<String>(value: c.id, child: Text(c.name));
                            }).toList(),
                            onChanged: (val) => setStateModal(() => selectedCategoryId = val),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      if (event != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting ? null : () async {
                              setStateModal(() => isSubmitting = true);
                              try {
                                await Provider.of<EventProvider>(context, listen: false).deleteEvent(event.id);
                                if (context.mounted) Navigator.pop(context);
                              } catch (e) {
                                if (context.mounted) {
                                  setStateModal(() => isSubmitting = false);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                }
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Delete'),
                          ),
                        ),
                      if (event != null) const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : () async {
                            setStateModal(() => isSubmitting = true);
                            try {
                              final eventData = {
                                'title': titleController.text,
                                'description': descController.text,
                                'location': locationController.text,
                                'date': dateController.text,
                                'time': timeController.text,
                                'capacity': int.tryParse(capacityController.text) ?? 50,
                                'price': double.tryParse(priceController.text) ?? 0,
                                'category': selectedCategoryId,
                              };
                              final provider = Provider.of<EventProvider>(context, listen: false);
                              if (event == null) {
                                await provider.addEvent(eventData);
                              } else {
                                await provider.updateEvent(event.id, eventData);
                              }
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (context.mounted) {
                                setStateModal(() => isSubmitting = false);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1018D5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isSubmitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(event == null ? 'Create' : 'Save Changes', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final events = eventProvider.events
        .where((e) => e.title.toLowerCase().contains(_searchQuery))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: SafeArea(
        child: eventProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Manage Events',
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(color: const Color(0xFFE9EAF5), borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Color(0xFF5A5A89)),
                          hintText: 'Search events',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.separated(
                        itemCount: events.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return _buildEventItem(event);
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventModal(),
        backgroundColor: const Color(0xFF1018D5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEventItem(Event event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EAF5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${event.date} • ${event.location}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF1018D5).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(event.categoryName, style: const TextStyle(color: Color(0xFF1018D5), fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                         Text('\$${event.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: () => _showEventModal(event: event), icon: const Icon(Icons.edit_outlined)),
            ],
          ),
          const Divider(),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventParticipantsScreen(event: event)),
                );
              },
              icon: const Icon(Icons.people_outline, size: 18),
              label: const Text('View Participants'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
