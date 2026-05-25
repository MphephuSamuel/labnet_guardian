import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../models/user_profile.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/profile/profile_info_card.dart';
import '../widgets/settings/settings_section.dart';
import '../widgets/settings/settings_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _avatarController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadProfile();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _enterEditMode(UserProfile? profile) {
    if (profile != null) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _displayNameController.text = profile.displayName;
      _avatarController.text = profile.avatar;
    }
    setState(() {
      _isEditing = true;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _isSaving = true;
    });

    try {
      await userProvider.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        displayName: _displayNameController.text.trim(),
        avatar: _avatarController.text.trim(),
      );

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _getAvatarInitial(String avatar) {
    if (avatar.isEmpty) return 'A';
    return avatar[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final userProvider = Provider.of<UserProvider>(context);
    final profile = userProvider.profile;

    return Scaffold(
      backgroundColor: AppColors.getBgColor(isDark),
      body: SafeArea(
        child: userProvider.isLoading && profile == null
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingDefault),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with back button, edit toggle, and theme toggle
                        _buildHeader(context, isDark, themeProvider, userProvider),
                        const SizedBox(height: AppConstants.paddingXl),

                        if (userProvider.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppConstants.paddingDefault),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.redAccent),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Error: ${userProvider.error}',
                                      style: const TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Profile Card
                        ProfileInfoCard(
                          name: profile?.displayName ?? 'Admin User',
                          email: profile?.email ?? 'admin@ump.ac.za',
                          role: profile?.role ?? 'Network Administrator',
                          avatarInitial: _getAvatarInitial(profile?.avatar ?? 'A'),
                        ),
                        const SizedBox(height: AppConstants.paddingXl),

                        // Info section (View/Edit modes)
                        _isEditing
                            ? _buildEditForm(isDark)
                            : _buildViewForm(isDark, profile),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    ThemeProvider themeProvider,
    UserProvider userProvider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        Text(
          'Profile',
          style: TextStyle(
            fontSize: AppConstants.fontSizeXLarge,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (_isEditing) {
                  setState(() {
                    _isEditing = false;
                  });
                } else {
                  _enterEditMode(userProvider.profile);
                }
              },
              child: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(width: AppConstants.paddingDefault),
            GestureDetector(
              onTap: themeProvider.toggleTheme,
              child: Icon(
                isDark ? Icons.wb_sunny : Icons.dark_mode,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewForm(bool isDark, UserProfile? profile) {
    return SettingsSection(
      title: AppConstants.accountInfoSection,
      isDark: isDark,
      children: [
        SettingsTile(
          icon: Icons.person_outline,
          label: 'First Name',
          value: profile?.firstName ?? '',
          iconColor: AppColors.iconPurple,
          isDark: isDark,
        ),
        SettingsTile(
          icon: Icons.person_outline,
          label: 'Last Name',
          value: profile?.lastName ?? '',
          iconColor: AppColors.iconPurple,
          isDark: isDark,
        ),
        SettingsTile(
          icon: Icons.badge_outlined,
          label: 'Display Name',
          value: profile?.displayName ?? 'Admin User',
          iconColor: AppColors.iconPurple,
          isDark: isDark,
        ),
        SettingsTile(
          icon: Icons.email_outlined,
          label: AppConstants.emailLabel,
          value: profile?.email ?? 'admin@ump.ac.za',
          iconColor: AppColors.iconPink,
          isDark: isDark,
        ),
        SettingsTile(
          icon: Icons.security_outlined,
          label: AppConstants.roleLabel,
          value: profile?.role ?? 'Network Administrator',
          iconColor: AppColors.iconBlue,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildEditForm(bool isDark) {
    return Column(
      children: [
        _buildEditField(
          label: 'First Name',
          controller: _firstNameController,
          isDark: isDark,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'First name is required';
            }
            return null;
          },
        ),
        _buildEditField(
          label: 'Last Name',
          controller: _lastNameController,
          isDark: isDark,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Last name is required';
            }
            return null;
          },
        ),
        _buildEditField(
          label: 'Display Name',
          controller: _displayNameController,
          isDark: isDark,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Display name is required';
            }
            return null;
          },
        ),
        _buildEditField(
          label: 'Avatar Initial / Letter',
          controller: _avatarController,
          isDark: isDark,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Avatar initial is required';
            }
            return null;
          },
        ),
        const SizedBox(height: AppConstants.paddingLg),
        GestureDetector(
          onTap: _isSaving ? null : _saveProfile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeMedium,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingDefault),
        GestureDetector(
          onTap: () {
            setState(() {
              _isEditing = false;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: AppColors.getBorderColor(isDark),
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Center(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.w600,
                  fontSize: AppConstants.fontSizeMedium,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AppConstants.paddingSm),
          Container(
            decoration: BoxDecoration(
              color: AppColors.getCardColor(isDark),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              border: Border.all(
                color: AppColors.getBorderColor(isDark),
              ),
            ),
            child: TextFormField(
              controller: controller,
              validator: validator,
              style: TextStyle(
                color: AppColors.getTextPrimary(isDark),
                fontSize: AppConstants.fontSizeMedium,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingDefault,
                  vertical: AppConstants.paddingDefault,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
