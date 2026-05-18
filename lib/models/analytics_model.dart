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
      averageBandwidth:
          (json["averageBandwidth"] ?? 0).toDouble(),

      averageBandwidthChange:
          (json["averageBandwidthChange"] ?? 0).toDouble(),

      activeDevices:
          json["activeDevices"] ?? 0,

      activeDevicesChange:
          json["activeDevicesChange"] ?? 0,

      threatsBlocked:
          json["threatsBlocked"] ?? 0,

      threatsChange:
          json["threatsChange"] ?? 0,

      anomalies:
          json["anomalies"] ?? 0,

      anomaliesChange:
          json["anomaliesChange"] ?? 0,

      traffic: List<double>.from(
        (json["traffic"] ?? []).map(
          (x) => (x as num).toDouble(),
        ),
      ),

      bandwidth: List<double>.from(
        (json["bandwidth"] ?? []).map(
          (x) => (x as num).toDouble(),
        ),
      ),

      threats: List<double>.from(
        (json["threats"] ?? []).map(
          (x) => (x as num).toDouble(),
        ),
      ),
    );
  }
}