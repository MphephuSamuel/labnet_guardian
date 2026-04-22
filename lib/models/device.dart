enum DeviceType { laptop, phone, tablet, other }
enum DeviceStatus { active, offline }

class Device {
  final String id;
  final String name;
  final String ipAddress;
  final String macAddress;
  final int speedMBs;
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
    required this.status,
    required this.type,
    this.isNew = false,
    this.isSuspicious = false,
  });
}
