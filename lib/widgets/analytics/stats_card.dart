import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final bool isDarkMode; // 🔥 NEW

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    required this.isDarkMode, // 🔥 REQUIRED
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = change.contains('-');

    final cardColor = AppColors.getCardColor(isDarkMode);
    final textPrimary = AppColors.getTextPrimary(isDarkMode);
    final textSecondary = AppColors.getTextSecondary(isDarkMode);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor, // ✅ dynamic
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black12,
            offset: const Offset(0, 3),
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
              color: textPrimary, // ✅ dynamic
            ),
          ),

          Text(
            title,
            style: TextStyle(color: textSecondary), // ✅ dynamic
          ),

          const SizedBox(height: 6),

          Text(
            change,
            style: TextStyle(
              color: isNegative
                  ? AppColors.critical
                  : AppColors.connection, // ✅ use your system
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}