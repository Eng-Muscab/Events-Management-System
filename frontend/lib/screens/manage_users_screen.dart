import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_widgets.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
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

  void _showUserModal({User? user}) {
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final passwordController = TextEditingController(); // Empty for updates unless changed
    String selectedRole = user?.role ?? 'user';
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        user == null ? 'Add User' : 'Edit User',
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
                  CustomTextField(label: 'Full Name', controller: nameController),
                  const SizedBox(height: 16),
                  CustomTextField(label: 'Email', controller: emailController, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: user == null ? 'Password' : 'New Password (Optional)', 
                    controller: passwordController, 
                    isPassword: true
                  ),
                  const SizedBox(height: 16),
                  const Text('Role', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                       color: const Color(0xFFE9EAF5),
                       borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedRole,
                        isExpanded: true,
                        items: ['user', 'organizer', 'admin'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value[0].toUpperCase() + value.substring(1)),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setStateModal(() {
                            selectedRole = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (user != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    setStateModal(() => isSubmitting = true);
                                    try {
                                      await Provider.of<UserProvider>(context, listen: false)
                                          .deleteUser(user.id);
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
                      if (user != null) const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  setStateModal(() => isSubmitting = true);
                                  try {
                                    final provider = Provider.of<UserProvider>(context, listen: false);
                                    final userData = {
                                      'name': nameController.text,
                                      'email': emailController.text,
                                      'role': selectedRole,
                                    };
                                    if (passwordController.text.isNotEmpty) {
                                      userData['password'] = passwordController.text;
                                    }
                                    
                                    if (user == null) {
                                      await provider.addUser(userData);
                                    } else {
                                      await provider.updateUser(user.id, userData);
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
                               : Text(user == null ? 'Create' : 'Save Changes', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
    final userProvider = Provider.of<UserProvider>(context);
    final users = userProvider.users
        .where((u) => u.name.toLowerCase().contains(_searchQuery) || u.email.toLowerCase().contains(_searchQuery))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Manage Users',
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EAF5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Color(0xFF5A5A89)),
                        hintText: 'Search users',
                        hintStyle: TextStyle(color: Color(0xFF9ca3af)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      itemCount: users.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return _buildUserItem(user);
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserModal(),
        backgroundColor: const Color(0xFF1018D5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUserItem(User user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF1018D5).withOpacity(0.1),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1018D5)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                user.role.toUpperCase(),
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF5A5A89)),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _showUserModal(user: user),
          icon: const Icon(Icons.edit_outlined, color: Colors.black),
        ),
      ],
    );
  }
}
