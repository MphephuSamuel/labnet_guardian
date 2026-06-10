import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../providers/theme_provider.dart';
import '../services/users_service.dart';
import '../utils/colors.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UsersService _usersService = UsersService();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  List<AppUser> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _usersService.fetchUsers();
      if (!mounted) {
        return;
      }
      setState(() {
        _users = users;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddAdminSheet() {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final secondNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final roleController = TextEditingController(text: 'admin');
    final emailController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = context.read<ThemeProvider>().isDarkMode;
        final cardColor = AppColors.getCardColor(isDark);
        final textColor = AppColors.getTextPrimary(isDark);
        final borderColor = AppColors.getBorderColor(
          isDark,
        ).withValues(alpha: 0.2);

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              Future<void> submit() async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                setModalState(() {
                  _isSubmitting = true;
                });

                try {
                  await _usersService.createAdmin(
                    firstName: firstNameController.text.trim(),
                    secondName: secondNameController.text.trim(),
                    lastName: lastNameController.text.trim(),
                    role: roleController.text.trim(),
                    email: emailController.text.trim(),
                  );

                  if (!mounted) {
                    return;
                  }

                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Admin added successfully')),
                  );
                  await _loadUsers();
                } catch (e) {
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().replaceFirst('Exception: ', ''),
                      ),
                    ),
                  );
                } finally {
                  if (mounted) {
                    setModalState(() {
                      _isSubmitting = false;
                    });
                  }
                }
              }

              return Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add Admin User',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a new admin account linked to your backend.',
                          style: TextStyle(
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: firstNameController,
                          label: 'First Name',
                          isDark: isDark,
                          textColor: textColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: secondNameController,
                          label: 'Second Name',
                          isDark: isDark,
                          textColor: textColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: lastNameController,
                          label: 'Last Name',
                          isDark: isDark,
                          textColor: textColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: roleController,
                          label: 'Role',
                          isDark: isDark,
                          textColor: textColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: emailController,
                          label: 'Email',
                          isDark: isDark,
                          textColor: textColor,
                          borderColor: borderColor,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) {
                              return 'Email is required';
                            }
                            final emailPattern = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            );
                            if (!emailPattern.hasMatch(email)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : submit,
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.person_add_alt_1),
                            label: Text(
                              _isSubmitting ? 'Adding...' : 'Add Admin',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.iconPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      firstNameController.dispose();
      secondNameController.dispose();
      lastNameController.dispose();
      roleController.dispose();
      emailController.dispose();
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
    required Color textColor,
    required Color borderColor,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator:
          validator ??
          (value) {
            if ((value ?? '').trim().isEmpty) {
              return '$label is required';
            }
            return null;
          },
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.getTextSecondary(isDark)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.iconPurple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.getBgColor(isDark),
      appBar: AppBar(
        backgroundColor: AppColors.getBgColor(isDark),
        title: const Text('Users'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAdminSheet,
        backgroundColor: AppColors.iconPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Admin'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : _users.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      'No users available yet',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return _buildUserCard(context, user, isDark);
                },
              ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AppUser user, bool isDark) {
    final createdLabel = user.createdAt == null
        ? 'Created date unavailable'
        : MaterialLocalizations.of(context).formatShortDate(user.createdAt!);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.getBorderColor(isDark).withValues(alpha: 0.15),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          user.fullName,
          style: TextStyle(
            color: AppColors.getTextPrimary(isDark),
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.email,
                style: TextStyle(color: AppColors.getTextSecondary(isDark)),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.iconBlue.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.iconBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      createdLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
