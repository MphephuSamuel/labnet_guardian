import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/profile/profile_info_card.dart';
import '../widgets/settings/settings_section.dart';
import '../widgets/settings/settings_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.getBgColor(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button and theme toggle
                _buildHeader(context, isDark, themeProvider),
                const SizedBox(height: AppConstants.paddingXl),

                // Profile Card
                const ProfileInfoCard(
                  name: AppConstants.userName,
                  email: AppConstants.userEmail,
                  role: AppConstants.userRole,
                  avatarInitial: AppConstants.avatarInitial,
                ),
                const SizedBox(height: AppConstants.paddingXl),

                // Account Information Section
                SettingsSection(
                  title: AppConstants.accountInfoSection,
                  isDark: isDark,
                  children: [
                    SettingsTile(
                      icon: Icons.person_outline,
                      label: AppConstants.fullNameLabel,
                      value: AppConstants.userName,
                      iconColor: AppColors.iconPurple,
                      isDark: isDark,
                    ),
                    SettingsTile(
                      icon: Icons.email_outlined,
                      label: AppConstants.emailLabel,
                      value: AppConstants.userEmail,
                      iconColor: AppColors.iconPink,
                      isDark: isDark,
                    ),
                    SettingsTile(
                      icon: Icons.security_outlined,
                      label: AppConstants.roleLabel,
                      value: AppConstants.userRole,
                      iconColor: AppColors.iconBlue,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
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
        GestureDetector(
          onTap: () {
            themeProvider.toggleTheme();
          },
          child: Icon(
            isDark ? Icons.wb_sunny : Icons.dark_mode,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
      ],
    );
  }
}
