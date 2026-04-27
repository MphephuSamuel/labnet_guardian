import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool isDark;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingDefault,
          vertical: AppConstants.paddingSm,
        ),
        child: Row(
          children: [
            Container(
              width: AppConstants.iconContainerSize,
              height: AppConstants.iconContainerSize,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
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
                      fontSize: AppConstants.fontSizeSmall,
                      color: isDark ? Colors.white38 : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSm),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.white24 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
