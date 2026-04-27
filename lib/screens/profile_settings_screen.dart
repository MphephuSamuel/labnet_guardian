import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/profile/profile_info_card.dart';
import '../widgets/settings/settings_section.dart';
import '../widgets/settings/settings_tile.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late bool _biometricEnabled = true;

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
                const SizedBox(height: AppConstants.paddingXl),

                // Security Settings Section
                _buildSecuritySettings(isDark),
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
          AppConstants.profileTitle,
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

  Widget _buildSecuritySettings(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: AppColors.darkBorderOpacity)
              : Colors.grey.shade200,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingDefault,
        vertical: AppConstants.paddingSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: AppConstants.iconContainerSize,
                height: AppConstants.iconContainerSize,
                decoration: BoxDecoration(
                  color: AppColors.iconPurple.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: const Icon(
                  Icons.fingerprint,
                  color: AppColors.iconPurple,
                ),
              ),
              const SizedBox(width: AppConstants.paddingDefault),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.biometricLabel,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSm),
                  Text(
                    AppConstants.biometricSubLabel,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSmall,
                      color: isDark
                          ? Colors.white38
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() {
                _biometricEnabled = value;
              });
            },
            activeThumbColor: AppColors.iconPurple,
          ),
        ],
      ),
    );
  }
}
