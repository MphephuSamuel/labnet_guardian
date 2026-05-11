enum DeviceType { laptop, phone, tablet, other }

enum DeviceStatus { active, offline }

class Device {
  final String id;
  final String name;
  final String ipAddress;
  final String macAddress;
  final int speedMBs;
  final int speedBps;
  final String speedText;
  final DeviceStatus status;
  final DeviceType type;
  final bool isNew;
  final bool isSuspicious;

  Device({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.macAddress,
    required this.speedMBs,
    required this.speedBps,
    required this.speedText,
    required this.status,
    required this.type,
    this.isNew = false,
    this.isSuspicious = false,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    final typeValue = (json['device_type'] ?? '').toString();
    return Device(
      id: json['id']?.toString() ?? json['mac']?.toString() ?? '',
      name:
          json['name']?.toString() ??
          json['hostname']?.toString() ??
          'Unknown Device',
      ipAddress: json['ip']?.toString() ?? 'N/A',
      macAddress: json['mac']?.toString() ?? 'N/A',
      speedMBs: json['speedMBs'] is int
          ? json['speedMBs'] as int
          : int.tryParse(json['speedMBs']?.toString() ?? '') ?? 0,
      speedBps: json['speedBps'] is int
          ? json['speedBps'] as int
          : int.tryParse(json['speedBps']?.toString() ?? '') ??
                ((json['speedMBs'] is int
                    ? (json['speedMBs'] as int) * 1000000
                    : int.tryParse(json['speedMBs']?.toString() ?? '') ?? 0)),
      speedText:
          json['speedText']?.toString() ??
          _formatSpeedText(
            json['speedBps'] is int
                ? json['speedBps'] as int
                : int.tryParse(json['speedBps']?.toString() ?? '') ??
                      ((json['speedMBs'] is int
                          ? (json['speedMBs'] as int) * 1000000
                          : int.tryParse(json['speedMBs']?.toString() ?? '') ??
                                0)),
          ),
      status: _parseStatus(json['status']?.toString()),
      type: _parseType(typeValue),
      isNew: json['isNew'] == true,
      isSuspicious: json['isSuspicious'] == true,
    );
  }

  static DeviceStatus _parseStatus(String? status) {
    if (status == null) return DeviceStatus.active;
    return status.toLowerCase() == 'offline'
        ? DeviceStatus.offline
        : DeviceStatus.active;
  }

  static String _formatSpeedText(int bps) {
    if (bps >= 1000000) {
      return '${(bps / 1000000).toStringAsFixed(1)} MB/s';
    }
    if (bps >= 1000) {
      return '${(bps / 1000).toStringAsFixed(1)} KB/s';
    }
    return '$bps B/s';
  }

  static DeviceType _parseType(String type) {
    final normalized = type.toLowerCase();
    if (normalized.contains('mobile device')) {
      return DeviceType.phone;
    }
    if (normalized.contains('computer')) {
      return DeviceType.laptop;
    }
    if (normalized.contains('tablet')) {
      return DeviceType.tablet;
    }
    if (normalized.contains('router') ||
        normalized.contains('network device') ||
        normalized.contains('unknown device')) {
      return DeviceType.other;
    }
    return DeviceType.other;
  }
}
