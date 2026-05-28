class AnalyticsModel {
  final double averageBandwidth;
  final double averageBandwidthChange;
  final int activeDevices;
  final int activeDevicesChange;
  final int threatsBlocked;
  final int threatsChange;
  final int anomalies;
  final int anomaliesChange;
  final List<double> traffic;
  final List<double> bandwidth;
  final List<double> threats;

  AnalyticsModel({
    required this.averageBandwidth,
    required this.averageBandwidthChange,
    required this.activeDevices,
    required this.activeDevicesChange,
    required this.threatsBlocked,
    required this.threatsChange,
    required this.anomalies,
    required this.anomaliesChange,
    required this.traffic,
    required this.bandwidth,
    required this.threats,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      averageBandwidth: (json["averageBandwidth"] ?? 0).toDouble(),
      averageBandwidthChange: (json["averageBandwidthChange"] ?? 0).toDouble(),
      activeDevices: (json["activeDevices"] ?? 0),
      activeDevicesChange: (json["activeDevicesChange"] ?? 0),
      threatsBlocked: (json["threatsBlocked"] ?? 0),
      threatsChange: (json["threatsChange"] ?? 0),
      anomalies: (json["anomalies"] ?? 0),
      anomaliesChange: (json["anomaliesChange"] ?? 0),
      traffic: (json["traffic"] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      bandwidth: (json["bandwidth"] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      threats: (json["threats"] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
    );
  }

  factory AnalyticsModel.empty() {
    return AnalyticsModel(
      averageBandwidth: 0,
      averageBandwidthChange: 0,
      activeDevices: 0,
      activeDevicesChange: 0,
      threatsBlocked: 0,
      threatsChange: 0,
      anomalies: 0,
      anomaliesChange: 0,
      traffic: [],
      bandwidth: [],
      threats: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "averageBandwidth": averageBandwidth,
      "averageBandwidthChange": averageBandwidthChange,
      "activeDevices": activeDevices,
      "activeDevicesChange": activeDevicesChange,
      "threatsBlocked": threatsBlocked,
      "threatsChange": threatsChange,
      "anomalies": anomalies,
      "anomaliesChange": anomaliesChange,
      "traffic": traffic,
      "bandwidth": bandwidth,
      "threats": threats,
    };
  }
}