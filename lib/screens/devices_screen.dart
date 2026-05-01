import 'package:flutter/material.dart';
import '../models/device.dart';
import '../widgets/devices/device_card.dart';
import '../widgets/devices/device_filter.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data based on screenshots
    final List<Device> mockDevices = [
      Device(
        id: '1',
        name: 'LAB-PC-001',
        ipAddress: '192.168.1.45',
        macAddress: '00:1B:44:11:3A:B7',
        speedMBs: 125,
        status: DeviceStatus.active,
        type: DeviceType.laptop,
      ),
      Device(
        id: '2',
        name: 'TABLET-ENG-015',
        ipAddress: '192.168.1.78',
        macAddress: 'A4:5E:60:E8:91:2C',
        speedMBs: 45,
        status: DeviceStatus.active,
        type: DeviceType.tablet,
        isSuspicious: true,
      ),
      Device(
        id: '3',
        name: 'PHONE-CS-023',
        ipAddress: '192.168.1.92',
        macAddress: 'D8:BB:C1:0E:7A:3D',
        speedMBs: 12,
        status: DeviceStatus.active,
        type: DeviceType.phone,
        isNew: true,
      ),
      Device(
        id: '4',
        name: 'LAB-PC-002',
        ipAddress: '192.168.1.46',
        macAddress: '00:1B:44:11:3A:B8',
        speedMBs: 0,
        status: DeviceStatus.offline,
        type: DeviceType.laptop,
      ),
      Device(
        id: '5',
        name: 'PHONE-ENG-04',
        ipAddress: '192.168.1.95',
        macAddress: 'A4:5E:60:E8:91:2D',
        speedMBs: 5,
        status: DeviceStatus.active,
        type: DeviceType.phone,
        isNew: true,
      ),
      Device(
        id: '6',
        name: 'IOT-SENSOR-01',
        ipAddress: '192.168.1.112',
        macAddress: 'AA:BB:CC:DD:EE:FF',
        speedMBs: 250,
        status: DeviceStatus.active,
        type: DeviceType.other,
        isSuspicious: true,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Connected Devices',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search devices...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
          const SizedBox(height: 24),
          const DeviceFilter(
            totalCount: 6,
            newCount: 2,
            suspiciousCount: 2,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: mockDevices.length,
              itemBuilder: (context, index) {
                return DeviceCard(device: mockDevices[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
