import 'package:flutter/material.dart';
import '../../models/device.dart';

class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    IconData getIconForType(DeviceType type) {
      switch (type) {
        case DeviceType.laptop:
          return Icons.laptop;
        case DeviceType.phone:
          return Icons.phone_android;
        case DeviceType.tablet:
          return Icons.tablet_mac;
        case DeviceType.other:
          return Icons.devices;
      }
    }

    Color getIconBackgroundColor(DeviceType type, bool isSuspicious) {
      if (isSuspicious) return Colors.orange.withValues(alpha: 0.2);
      switch (type) {
        case DeviceType.laptop:
        case DeviceType.phone:
          return Colors.purple.withValues(alpha: 0.1);
        case DeviceType.tablet:
          return Colors.orange.withValues(alpha: 0.1);
        case DeviceType.other:
          return Colors.blue.withValues(alpha: 0.1);
      }
    }

    Color getIconColor(DeviceType type, bool isSuspicious) {
      if (isSuspicious) return Colors.orange;
      switch (type) {
        case DeviceType.laptop:
        case DeviceType.phone:
          return Colors.purple;
        case DeviceType.tablet:
          return Colors.orange;
        case DeviceType.other:
          return Colors.blue;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: getIconBackgroundColor(
                    device.type,
                    device.isSuspicious,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  getIconForType(device.type),
                  color: getIconColor(device.type, device.isSuspicious),
                  size: 30,
                ),
              ),
              if (device.isSuspicious)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (device.isNew) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'New',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${device.ipAddress} • ${device.macAddress}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.wifi, size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      device.speedText,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: device.status == DeviceStatus.active
                            ? Colors.green.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        device.status.name,
                        style: TextStyle(
                          color: device.status == DeviceStatus.active
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
