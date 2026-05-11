import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/settings/settings_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _biometricEnabled = true;
  bool _anomalyDetectionEnabled = true;
  double _detectionSensitivity = 0.5;
  bool _autoBlockThreats = false;
  bool _simulationMode = false;
  bool _emailAlerts = true;
  bool _pushNotifications = true;

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _macController = TextEditingController();

  final List<String> _trustedIpRanges = [
    '192.168.1.0/24',
    '10.0.0.0/8',
  ];

  final List<String> _trustedMacAddresses = [
    'AA:BB:CC:DD:EE:01',
    'AA:BB:CC:DD:EE:02',
  ];

  @override
  void dispose() {
    _ipController.dispose();
    _macController.dispose();
    super.dispose();
  }

  String get _sensitivityLabel {
    if (_detectionSensitivity <= 0.33) {
      return 'Low';
    } else if (_detectionSensitivity <= 0.66) {
      return 'Medium';
    }
    return 'High';
  }

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
                _buildHeader(context, isDark, themeProvider),
                const SizedBox(height: AppConstants.paddingXl),
                _buildSecurityConfiguration(isDark),
                const SizedBox(height: AppConstants.paddingLg),
                _buildWhitelistManagement(isDark),
                const SizedBox(height: AppConstants.paddingLg),
                _buildNotificationPreferences(isDark),
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

  Widget _buildSecurityConfiguration(bool isDark) {
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
          value: _anomalyDetectionEnabled,
          onChanged: (value) => setState(() {
            _anomalyDetectionEnabled = value;
          }),
        ),
        _buildSensitivityRow(isDark),
        _buildToggleRow(
          isDark: isDark,
          icon: Icons.shield_moon,
          iconColor: AppColors.iconPink,
          label: 'Auto-Block Threats',
          subtitle: 'Automatically block detected threats',
          value: _autoBlockThreats,
          onChanged: (value) => setState(() {
            _autoBlockThreats = value;
          }),
        ),
        _buildToggleRow(
          isDark: isDark,
          icon: Icons.flash_on,
          iconColor: AppColors.iconBlue,
          label: 'Simulation Mode',
          subtitle: 'Test alerts without real threats',
          value: _simulationMode,
          onChanged: (value) => setState(() {
            _simulationMode = value;
          }),
        ),
      ],
    );
  }

  Widget _buildWhitelistManagement(bool isDark) {
    return SettingsSection(
      title: 'Whitelist Management',
      isDark: isDark,
      children: [
        _buildListInputSection(
          isDark: isDark,
          label: 'Trusted IP Ranges',
          controller: _ipController,
          placeholder: '192.168.1.0/24',
          onAdd: _addIpRange,
          items: _trustedIpRanges,
        ),
        _buildListInputSection(
          isDark: isDark,
          label: 'Trusted MAC Addresses',
          controller: _macController,
          placeholder: 'AA:BB:CC:DD:EE:FF',
          onAdd: _addMacAddress,
          items: _trustedMacAddresses,
        ),
      ],
    );
  }

  Widget _buildNotificationPreferences(bool isDark) {
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
          value: _emailAlerts,
          onChanged: (value) => setState(() {
            _emailAlerts = value;
          }),
        ),
        _buildToggleRow(
          isDark: isDark,
          icon: Icons.notifications_active,
          iconColor: AppColors.iconBlue,
          label: 'Push Notifications',
          subtitle: 'Receive real-time push alerts',
          value: _pushNotifications,
          onChanged: (value) => setState(() {
            _pushNotifications = value;
          }),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: iconColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSensitivityRow(bool isDark) {
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
                child: const Icon(Icons.speed, color: AppColors.iconPurple, size: 24),
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
                        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                      ),
                      child: Text(
                        _sensitivityLabel,
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
            value: _detectionSensitivity,
            activeColor: AppColors.iconPurple,
            inactiveColor: AppColors.iconPurple.withOpacity(0.25),
            min: 0,
            max: 1,
            divisions: 100,
            label: _sensitivityLabel,
            onChanged: (value) {
              setState(() {
                _detectionSensitivity = value;
              });
            },
          ),
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
                    border: Border.all(
                      color: AppColors.getBorderColor(isDark),
                    ),
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
                      style: TextStyle(
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    backgroundColor: isDark
                        ? Colors.white10
                        : Colors.grey.shade100,
                    side: BorderSide(
                      color: AppColors.getBorderColor(isDark),
                    ),
                    deleteIcon: Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    onDeleted: () {
                      setState(() {
                        items.remove(item);
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  void _addIpRange() {
    final value = _ipController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _trustedIpRanges.add(value);
      _ipController.clear();
    });
  }

  void _addMacAddress() {
    final value = _macController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _trustedMacAddresses.add(value);
      _macController.clear();
    });
  }
}
