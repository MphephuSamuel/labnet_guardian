import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isDark;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: AppConstants.paddingDefault),
        Container(
          decoration: BoxDecoration(
            color: AppColors.getCardColor(isDark),
            borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder.withValues(
                      alpha: AppColors.darkBorderOpacity)
                  : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: List.generate(
              children.length,
              (index) => Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingDefault,
                      ),
                      child: Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.dividerDark
                                .withValues(alpha: AppColors.dividerDarkOpacity)
                            : Colors.grey.shade200,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
