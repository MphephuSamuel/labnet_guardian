import 'dart:async';

import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/network_scan_service.dart';
import '../widgets/devices/device_card.dart';
import '../widgets/devices/device_filter.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  late Future<ApiResult<List<Device>>> _devicesFuture;
  Timer? _refreshTimer;
  DateTime? _lastRefreshTime;

  @override
  void initState() {
    super.initState();
    _loadDevices();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadDevices(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _devicesFuture = NetworkScanService.fetchDevices();
      _lastRefreshTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 8),
          if (_lastRefreshTime != null)
            Text(
              'Last updated: ${_lastRefreshTime!.toLocal().toString().split('.').first}',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12,
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<ApiResult<List<Device>>>(
              future: _devicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.data!.hasError) {
                  final errorMessage =
                      snapshot.data?.error ??
                      'Unable to load connected devices.';
                  return Center(
                    child: Text(
                      errorMessage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }

                final devices = snapshot.data!.data ?? <Device>[];
                final suspiciousCount = devices
                    .where((device) => device.isSuspicious)
                    .length;
                final newCount = devices.where((device) => device.isNew).length;

                return Column(
                  children: [
                    DeviceFilter(
                      totalCount: devices.length,
                      newCount: newCount,
                      suspiciousCount: suspiciousCount,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadDevices,
                        child: devices.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 48.0,
                                      ),
                                      child: Text(
                                        'No connected devices were discovered. Try rerunning the scan or check the network connection.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                itemCount: devices.length,
                                itemBuilder: (context, index) {
                                  return DeviceCard(device: devices[index]);
                                },
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
