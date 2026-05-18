import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final bool isDarkMode;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = change.startsWith('-');

    final cardColor = AppColors.getCardColor(isDarkMode);
    final textPrimary = AppColors.getTextPrimary(isDarkMode);
    final textSecondary = AppColors.getTextSecondary(isDarkMode);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(0, 3),
            color: isDarkMode
                ? Colors.black.withOpacity(0.35)
                : Colors.black12,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),

          const SizedBox(height: 10),

          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            change,
            style: TextStyle(
              color: isNegative
                  ? AppColors.critical
                  : AppColors.connection,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}