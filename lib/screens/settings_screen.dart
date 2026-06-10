import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'change_password_screen.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/settings/settings_section.dart';
import '../widgets/settings/settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _macController = TextEditingController();

  double? _localSensitivity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUserData();
    });
  }

  @override
  void dispose() {
    _ipController.dispose();
    _macController.dispose();
    super.dispose();
  }

  String _getSensitivityLabel(double val) {
    if (val <= 0.33) {
      return 'Low';
    } else if (val <= 0.66) {
      return 'Medium';
    }
    return 'High';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final userProvider = Provider.of<UserProvider>(context);

    // Initial load check
    final settings = userProvider.settings;
    if (_localSensitivity == null && settings != null) {
      _localSensitivity = settings.security.detectionSensitivity;
    }

    return Scaffold(
      backgroundColor: AppColors.getBgColor(isDark),
      body: SafeArea(
        child: userProvider.isLoading && settings == null
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, isDark, themeProvider),
                      const SizedBox(height: AppConstants.paddingXl),
                      if (userProvider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.paddingDefault,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusSm,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Error: ${userProvider.error}',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      _buildSecurityConfiguration(isDark, userProvider),
                      const SizedBox(height: AppConstants.paddingLg),
                      _buildAccountSecurity(isDark),
                      const SizedBox(height: AppConstants.paddingLg),
                      _buildWhitelistManagement(isDark, userProvider),
                      const SizedBox(height: AppConstants.paddingLg),
                      _buildNotificationPreferences(isDark, userProvider),
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
          'System Settings',
          style: TextStyle(
            fontSize: AppConstants.fontSizeXLarge,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        GestureDetector(
          onTap: themeProvider.toggleTheme,
          child: Icon(
            isDark ? Icons.wb_sunny : Icons.dark_mode,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityConfiguration(bool isDark, UserProvider userProvider) {
    final settings = userProvider.settings;
    final anomaly = settings?.security.anomalyDetectionEnabled ?? true;
    final autoBlock = settings?.security.autoBlockThreats ?? false;
    final simulation = settings?.security.simulationMode ?? false;

    return SettingsSection(
      title: 'Security Configuration',
      isDark: isDark,
      children: [
        _buildToggleRow(
          isDark: isDark,
          icon: Icons.shield,
          iconColor: AppColors.iconPurple,
          label: 'Anomaly Detection',
          subtitle: 'Monitor unusual network behavior',
          value: anomaly,
          onChanged: (value) => _updateSecurity(userProvider, anomaly: value),
        ),
        _buildSensitivityRow(isDark, userProvider),
        _buildToggleRow(
          isDark: isDark,
          icon: Icons.shield_moon,
          iconColor: AppColors.iconPink,
          label: 'Auto-Block Threats',
          subtitle: 'Automatically block detected threats',
          value: autoBlock,
          onChanged: (value) => _updateSecurity(userProvider, autoBlock: value),
        ),
        _buildToggleRow(
          isDark: isDark,
          icon: Icons.flash_on,
          iconColor: AppColors.iconBlue,
          label: 'Simulation Mode',
          subtitle: 'Test alerts without real threats',
          value: simulation,
          onChanged: (value) =>
              _updateSecurity(userProvider, simulation: value),
        ),
      ],
    );
  }

  Widget _buildAccountSecurity(bool isDark) {
    return SettingsSection(
      title: 'Account Security',
      isDark: isDark,
      children: [
        SettingsTile(
          icon: Icons.lock_outline,
          label: 'Change Password',
          value: 'Update your login password',
          iconColor: AppColors.iconPink,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSensitivityRow(bool isDark, UserProvider userProvider) {
    final settings = userProvider.settings;
    final currentSensitivity =
        _localSensitivity ?? settings?.security.detectionSensitivity ?? 0.5;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingDefault,
        vertical: AppConstants.paddingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppConstants.iconContainerSize,
                height: AppConstants.iconContainerSize,
                decoration: BoxDecoration(
                  color: AppColors.iconPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: const Icon(
                  Icons.speed,
                  color: AppColors.iconPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.paddingDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detection Sensitivity',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingSm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.iconPink.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusSm,
                        ),
                      ),
                      child: Text(
                        _getSensitivityLabel(currentSensitivity),
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          fontWeight: FontWeight.w600,
                          color: AppColors.iconPink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Slider(
            value: currentSensitivity,
            activeColor: AppColors.iconPurple,
            inactiveColor: AppColors.iconPurple.withOpacity(0.25),
            min: 0,
            max: 1,
            divisions: 100,
            label: _getSensitivityLabel(currentSensitivity),
            onChanged: (value) {
              setState(() {
                _localSensitivity = value;
              });
            },
            onChangeEnd: (value) =>
                _updateSecurity(userProvider, sensitivity: value),
          ),
        ],
      ),
    );
  }

  Widget _buildWhitelistManagement(bool isDark, UserProvider userProvider) {
    return SettingsSection(
      title: 'Whitelist Management',
      isDark: isDark,
      children: [
        _buildListInputSection(
          isDark: isDark,
          label: 'Trusted IP Ranges',
          controller: _ipController,
          placeholder: '192.168.1.0/24',
          onAdd: () => _addIpRange(userProvider),
          items: userProvider.trustedIpRanges,
          onDelete: (item) => _deleteWhitelistItem(userProvider, 'ip', item),
        ),
        _buildListInputSection(
          isDark: isDark,
          label: 'Trusted MAC Addresses',
          controller: _macController,
          placeholder: 'AA:BB:CC:DD:EE:FF',
          onAdd: () => _addMacAddress(userProvider),
          items: userProvider.trustedMacAddresses,
          onDelete: (item) => _deleteWhitelistItem(userProvider, 'mac', item),
        ),
      ],
    );
  }

  Widget _buildNotificationPreferences(bool isDark, UserProvider userProvider) {
    final settings = userProvider.settings;
    final email = settings?.notifications.emailAlerts ?? true;
    final push = settings?.notifications.pushNotifications ?? true;

    return SettingsSection(
      title: 'Notification Preferences',
      isDark: isDark,
      children: [
        _buildToggleRow(
          isDark: isDark,
          icon: Icons.email,
          iconColor: AppColors.iconPink,
          label: 'Email Alerts',
          subtitle: 'Receive security alerts via email',
          value: email,
          onChanged: (value) =>
              _updateNotifications(userProvider, email: value),
        ),
        _buildToggleRow(
          isDark: isDark,
          icon: Icons.notifications_active,
          iconColor: AppColors.iconBlue,
          label: 'Push Notifications',
          subtitle: 'Receive real-time push alerts',
          value: push,
          onChanged: (value) => _updateNotifications(userProvider, push: value),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingDefault,
        vertical: AppConstants.paddingSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: AppConstants.iconContainerSize,
                  height: AppConstants.iconContainerSize,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: AppConstants.paddingDefault),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeMedium,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSm),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: iconColor),
        ],
      ),
    );
  }

  Widget _buildListInputSection({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    required String placeholder,
    required VoidCallback onAdd,
    required List<String> items,
    required ValueChanged<String> onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppConstants.paddingDefault,
        right: AppConstants.paddingDefault,
        top: AppConstants.paddingSm,
        bottom: AppConstants.paddingDefault,
      ),
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
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.getCardColor(isDark),
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                    border: Border.all(color: AppColors.getBorderColor(isDark)),
                  ),
                  child: TextField(
                    controller: controller,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(isDark),
                      fontSize: AppConstants.fontSizeMedium,
                    ),
                    decoration: InputDecoration(
                      hintText: placeholder,
                      hintStyle: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingDefault,
                        vertical: AppConstants.paddingDefault,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingSm),
              Container(
                width: AppConstants.iconContainerSize,
                height: AppConstants.iconContainerSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: onAdd,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSm),
          Wrap(
            spacing: AppConstants.paddingSm,
            runSpacing: AppConstants.paddingSm,
            children: items
                .map(
                  (item) => Chip(
                    label: Text(
                      item,
                      style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                    ),
                    backgroundColor: isDark
                        ? Colors.white10
                        : Colors.grey.shade100,
                    side: BorderSide(color: AppColors.getBorderColor(isDark)),
                    deleteIcon: Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    onDeleted: () => onDelete(item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // --- Async Backend Updates ---

  Future<void> _updateSecurity(
    UserProvider provider, {
    bool? anomaly,
    double? sensitivity,
    bool? autoBlock,
    bool? simulation,
  }) async {
    final currentSettings = provider.settings?.security;
    try {
      await provider.updateSecuritySettings(
        anomaly: anomaly ?? currentSettings?.anomalyDetectionEnabled ?? true,
        sensitivity:
            sensitivity ?? currentSettings?.detectionSensitivity ?? 0.5,
        autoBlock: autoBlock ?? currentSettings?.autoBlockThreats ?? false,
        simulation: simulation ?? currentSettings?.simulationMode ?? false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update security settings: $e')),
        );
      }
    }
  }

  Future<void> _updateNotifications(
    UserProvider provider, {
    bool? email,
    bool? push,
  }) async {
    final currentNotifications = provider.settings?.notifications;
    try {
      await provider.updateNotificationSettings(
        email: email ?? currentNotifications?.emailAlerts ?? true,
        push: push ?? currentNotifications?.pushNotifications ?? true,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update notifications: $e')),
        );
      }
    }
  }

  Future<void> _addIpRange(UserProvider provider) async {
    final value = _ipController.text.trim();
    if (value.isEmpty) return;
    try {
      await provider.addWhitelistItem(type: 'ip', value: value);
      _ipController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add IP: $e')));
      }
    }
  }

  Future<void> _addMacAddress(UserProvider provider) async {
    final value = _macController.text.trim();
    if (value.isEmpty) return;
    try {
      await provider.addWhitelistItem(type: 'mac', value: value);
      _macController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add MAC: $e')));
      }
    }
  }

  Future<void> _deleteWhitelistItem(
    UserProvider provider,
    String type,
    String value,
  ) async {
    try {
      await provider.removeWhitelistItem(type: type, value: value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to remove item: $e')));
      }
    }
  }
}
