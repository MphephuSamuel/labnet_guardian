import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/device.dart';

class NetworkProvider extends ChangeNotifier {
  late IO.Socket socket;
  List<Device> devices = [];
  bool isConnected = false;
  final _storage = const FlutterSecureStorage();

  NetworkProvider() {
    _initSocket();
  }

  void _initSocket() async {
    // 1. Load the last known scan immediately so the UI isn't empty!
    try {
      final cached = await _storage.read(key: 'last_scan');
      if (cached != null) {
        final List<dynamic> rawDevices = jsonDecode(cached);
        devices = _parseDevices(rawDevices);
        notifyListeners();
      }
    } catch (e) {
      print("❌ Failed to load cached scan: $e");
    }

    // 2. Get the backend URL from the .env file
    final backendUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000';

    // 3. Connect to the Node.js backend
    socket = IO.io(
      backendUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // Force websockets
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('✅ Connected to LabNet Backend WebSockets');
      isConnected = true;
      notifyListeners();
    });

    socket.on('network_update', (data) {
      print('📡 Received Live Scan Data!');
      try {
        final List<dynamic> rawDevices = data as List<dynamic>;
        
        // Prevent UI from flashing empty if the scanner momentarily glitches and sends 0 devices
        if (rawDevices.isEmpty && devices.isNotEmpty) {
           print("⚠️ Scanner sent 0 devices, keeping last known state to prevent flashing.");
           return;
        }

        // Save it so we have it next time the app opens!
        _storage.write(key: 'last_scan', value: jsonEncode(rawDevices));

        devices = _parseDevices(rawDevices);
        notifyListeners();
      } catch (e) {
        print("❌ Error parsing websocket data: $e");
      }
    });

    socket.onDisconnect((_) {
      print('🔌 Disconnected from WebSockets');
      isConnected = false;
      notifyListeners();
    });
  }

  List<Device> _parseDevices(List<dynamic> rawDevices) {
    return rawDevices.map((d) {
      final String ip = d['ip'] ?? '';
      final String mac = d['mac'] ?? '';
      final String hostname = d['hostname'] ?? 'N/A';
      final String rawType = d['type'] ?? 'Unknown';
      
      final double bps = (d['bandwidth'] ?? 0.0).toDouble();
      final int speedKbs = (bps / 1024).round();
      final String rawStatus = d['status'] ?? 'active';

      return Device(
        id: mac,
        name: hostname,
        ipAddress: ip,
        macAddress: mac,
        speedMBs: speedKbs,
        status: rawStatus == 'offline' ? DeviceStatus.offline : DeviceStatus.active,
        type: _mapType(rawType),
        isSuspicious: rawType == 'Unknown Device',
        isNew: false,
      );
    }).toList();
  }

  DeviceType _mapType(String type) {
    final t = type.toLowerCase();
    if (t.contains('mobile') || t.contains('phone')) return DeviceType.phone;
    if (t.contains('tablet')) return DeviceType.tablet;
    if (t.contains('computer') || t.contains('laptop') || t.contains('desktop')) return DeviceType.laptop;
    return DeviceType.other;
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }
}
