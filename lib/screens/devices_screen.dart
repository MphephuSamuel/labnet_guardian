import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../widgets/devices/device_card.dart';
import '../widgets/devices/device_filter.dart';
import '../providers/network_provider.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Read live data from our WebSocket NetworkProvider
    final networkProvider = context.watch<NetworkProvider>();
    final List<Device> liveDevices = networkProvider.devices;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Connected Devices',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (networkProvider.isConnected)
                const Row(
                  children: [
                    Icon(Icons.circle, color: Colors.green, size: 12),
                    SizedBox(width: 4),
                    Text('Live', style: TextStyle(color: Colors.green)),
                  ],
                )
              else
                const Row(
                  children: [
                    Icon(Icons.circle, color: Colors.red, size: 12),
                    SizedBox(width: 4),
                    Text('Offline', style: TextStyle(color: Colors.red)),
                  ],
                ),
            ],
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
          DeviceFilter(
            totalCount: liveDevices.length,
            newCount: liveDevices.where((d) => d.isNew).length,
            suspiciousCount: liveDevices.where((d) => d.isSuspicious).length,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
                    itemCount: liveDevices.length,
                    itemBuilder: (context, index) {
                      return DeviceCard(device: liveDevices[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
