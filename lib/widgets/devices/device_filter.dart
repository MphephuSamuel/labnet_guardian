import 'package:flutter/material.dart';

class DeviceFilter extends StatelessWidget {
  final int totalCount;
  final int newCount;
  final int suspiciousCount;

  const DeviceFilter({
    super.key,
    required this.totalCount,
    required this.newCount,
    required this.suspiciousCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildChip(
          context,
          label: '$totalCount Total',
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
        ),
        const SizedBox(width: 12),
        _buildChip(
          context,
          label: '$newCount New',
          backgroundColor: Colors.purple.withValues(alpha: 0.1),
          textColor: Colors.purple.shade300, // Slightly lighter for dark mode compatibility, or use adaptive
        ),
        const SizedBox(width: 12),
        _buildChip(
          context,
          label: '$suspiciousCount Suspicious',
          backgroundColor: Colors.orange.withValues(alpha: 0.2),
          textColor: Colors.orange.shade700,
        ),
      ],
    );
  }

  Widget _buildChip(BuildContext context, {required String label, required Color backgroundColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
