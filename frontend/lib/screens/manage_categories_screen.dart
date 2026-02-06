import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_widgets.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  IconData _getIconForCategory(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('tech')) return Icons.code;
    if (lowerName.contains('music')) return Icons.music_note;
    if (lowerName.contains('sport')) return Icons.sports_soccer; 
    if (lowerName.contains('art')) return Icons.palette;
    if (lowerName.contains('food') || lowerName.contains('drink')) return Icons.restaurant;
    if (lowerName.contains('travel')) return Icons.flight;
    if (lowerName.contains('business')) return Icons.business;
    return Icons.category;
  }

  void _showCategoryModal({Category? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController = TextEditingController(text: category?.description ?? '');
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category == null ? 'Add Category' : 'Edit Category',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextField(label: 'Category Name', controller: nameController),
                const SizedBox(height: 16),
                CustomTextField(label: 'Description', controller: descController),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (category != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  setStateModal(() => isSubmitting = true);
                                  try {
                                    // Make sure to use ! since we entered the if block check
                                    await Provider.of<CategoryProvider>(context, listen: false)
                                        .deleteCategory(category!.id);
                                    if (context.mounted) Navigator.pop(context);
                                  } catch (e) {
                                    if (context.mounted) { // Check mounted before set state if possible, though setStateModal is local
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
                    if (category != null) const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                setStateModal(() => isSubmitting = true);
                                try {
                                  final provider = Provider.of<CategoryProvider>(context, listen: false);
                                  if (category == null) {
                                    await provider.addCategory(nameController.text, descController.text);
                                  } else {
                                    // Use ! for safety
                                    await provider.updateCategory(category!.id, nameController.text, descController.text);
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
                             : Text(category == null ? 'Create' : 'Save Changes', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories
        .where((c) => c.name.toLowerCase().contains(_searchQuery))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null, // No AppBar to match design and avoid duplication
      body: SafeArea(
        child: categoryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Manage Categories',
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EAF5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Color(0xFF5A5A89)),
                        hintText: 'Search categories',
                        hintStyle: TextStyle(color: Color(0xFF9ca3af)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // List
                  Expanded(
                    child: ListView.separated(
                      itemCount: categories.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return GestureDetector(
                          onTap: () => _showCategoryModal(category: category),
                          child: Container(
                            color: Colors.transparent, // Hit test
                            child: Row(
                              children: [
                                // Icon Container
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE9EAF5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getIconForCategory(category.name),
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    category.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Colors.grey),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryModal(),
        backgroundColor: const Color(0xFF1018D5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
