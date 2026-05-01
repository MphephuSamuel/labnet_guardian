import 'package:flutter/material.dart';
import '../utils/colors.dart';

// ─── Alert severity ───────────────────────────────────────────────────────────
enum AlertSeverity { critical, warning, info }

extension AlertSeverityX on AlertSeverity {
  String get label {
    switch (this) {
      case AlertSeverity.critical:
        return 'CRITICAL';
      case AlertSeverity.warning:
        return 'WARNING';
      case AlertSeverity.info:
        return 'INFO';
    }
  }

  Color get color {
    switch (this) {
      case AlertSeverity.critical:
        return AppColors.critical;
      case AlertSeverity.warning:
        return AppColors.warning;
      case AlertSeverity.info:
        return AppColors.info;
    }
  }

  Color get bgLight {
    switch (this) {
      case AlertSeverity.critical:
        return const Color(0xFFFFEBEB);
      case AlertSeverity.warning:
        return const Color(0xFFFFF8EB);
      case AlertSeverity.info:
        return const Color(0xFFEFF6FF);
    }
  }

  IconData get icon {
    switch (this) {
      case AlertSeverity.critical:
        return Icons.shield_outlined;
      case AlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case AlertSeverity.info:
        return Icons.info_outline_rounded;
    }
  }

  static AlertSeverity fromString(String s) {
    switch (s.toLowerCase()) {
      case 'critical':
        return AlertSeverity.critical;
      case 'warning':
        return AlertSeverity.warning;
      default:
        return AlertSeverity.info;
    }
  }
}

// ─── Alert model ─────────────────────────────────────────────────────────────
class AlertItem {
  final String id;
  final String title;
  final String description;
  final String device;
  final String ip;
  final String time;
  final AlertSeverity severity;

  const AlertItem({
    required this.id,
    required this.title,
    required this.description,
    required this.device,
    required this.ip,
    required this.time,
    required this.severity,
  });

  factory AlertItem.fromJson(Map<String, dynamic> j) => AlertItem(
    id: j['id']?.toString() ?? '',
    title: j['title'] ?? '',
    description: j['description'] ?? '',
    device: j['device'] ?? '',
    ip: j['ip'] ?? '',
    time: j['time'] ?? '',
    severity: AlertSeverityX.fromString(j['severity'] ?? 'info'),
  );
}
