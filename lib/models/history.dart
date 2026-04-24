import 'package:flutter/material.dart';
import '../providers/app_theme.dart';

// ─── History event type ───────────────────────────────────────────────────────
enum HistoryType { connection, disconnection, anomaly, update, scan }

extension HistoryTypeX on HistoryType {
  String get label {
    switch (this) {
      case HistoryType.connection:    return 'Connection';
      case HistoryType.disconnection: return 'Disconnection';
      case HistoryType.anomaly:       return 'Anomaly';
      case HistoryType.update:        return 'Update';
      case HistoryType.scan:          return 'Scan';
    }
  }

  Color get color {
    switch (this) {
      case HistoryType.connection:    return AppColors.connection;
      case HistoryType.disconnection: return const Color(0xFF9CA3AF);
      case HistoryType.anomaly:       return AppColors.warning;
      case HistoryType.update:        return AppColors.info;
      case HistoryType.scan:          return AppColors.primary;
    }
  }

  IconData get icon {
    switch (this) {
      case HistoryType.connection:    return Icons.wifi_rounded;
      case HistoryType.disconnection: return Icons.wifi_off_rounded;
      case HistoryType.anomaly:       return Icons.warning_amber_rounded;
      case HistoryType.update:        return Icons.system_update_outlined;
      case HistoryType.scan:          return Icons.radar_rounded;
    }
  }

  static HistoryType fromString(String s) {
    switch (s.toLowerCase()) {
      case 'connection':    return HistoryType.connection;
      case 'disconnection': return HistoryType.disconnection;
      case 'anomaly':       return HistoryType.anomaly;
      case 'update':        return HistoryType.update;
      case 'scan':          return HistoryType.scan;
      default:              return HistoryType.connection;
    }
  }
}

// ─── History item ─────────────────────────────────────────────────────────────
class HistoryItem {
  final String id;
  final String title;
  final String device;
  final String ip;
  final String time;
  final String dateGroup;
  final HistoryType type;

  const HistoryItem({
    required this.id,
    required this.title,
    required this.device,
    required this.ip,
    required this.time,
    required this.dateGroup,
    required this.type,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> j) => HistoryItem(
        id:        j['id']?.toString() ?? '',
        title:     j['title'] ?? '',
        device:    j['device'] ?? '',
        ip:        j['ip'] ?? '',
        time:      j['time'] ?? '',
        dateGroup: j['date_group'] ?? 'Today',
        type:      HistoryTypeX.fromString(j['type'] ?? 'connection'),
      );
}

