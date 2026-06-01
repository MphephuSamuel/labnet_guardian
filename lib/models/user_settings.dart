class SecuritySettings {
  bool anomalyDetectionEnabled;
  double detectionSensitivity;
  bool autoBlockThreats;
  bool simulationMode;

  SecuritySettings({
    required this.anomalyDetectionEnabled,
    required this.detectionSensitivity,
    required this.autoBlockThreats,
    required this.simulationMode,
  });

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      anomalyDetectionEnabled: json['anomalyDetectionEnabled'] ?? true,
      detectionSensitivity: (json['detectionSensitivity'] ?? 0.5).toDouble(),
      autoBlockThreats: json['autoBlockThreats'] ?? false,
      simulationMode: json['simulationMode'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anomalyDetectionEnabled': anomalyDetectionEnabled,
      'detectionSensitivity': detectionSensitivity,
      'autoBlockThreats': autoBlockThreats,
      'simulationMode': simulationMode,
    };
  }

  SecuritySettings copyWith({
    bool? anomalyDetectionEnabled,
    double? detectionSensitivity,
    bool? autoBlockThreats,
    bool? simulationMode,
  }) {
    return SecuritySettings(
      anomalyDetectionEnabled: anomalyDetectionEnabled ?? this.anomalyDetectionEnabled,
      detectionSensitivity: detectionSensitivity ?? this.detectionSensitivity,
      autoBlockThreats: autoBlockThreats ?? this.autoBlockThreats,
      simulationMode: simulationMode ?? this.simulationMode,
    );
  }
}

class NotificationSettings {
  bool emailAlerts;
  bool pushNotifications;

  NotificationSettings({
    required this.emailAlerts,
    required this.pushNotifications,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      emailAlerts: json['emailAlerts'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emailAlerts': emailAlerts,
      'pushNotifications': pushNotifications,
    };
  }

  NotificationSettings copyWith({
    bool? emailAlerts,
    bool? pushNotifications,
  }) {
    return NotificationSettings(
      emailAlerts: emailAlerts ?? this.emailAlerts,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }
}

class UserSettings {
  bool biometricEnabled;
  String themeMode;
  SecuritySettings security;
  NotificationSettings notifications;

  UserSettings({
    required this.biometricEnabled,
    required this.themeMode,
    required this.security,
    required this.notifications,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      biometricEnabled: json['biometricEnabled'] ?? true,
      themeMode: json['themeMode'] ?? 'dark',
      security: SecuritySettings.fromJson(json['security'] ?? {}),
      notifications: NotificationSettings.fromJson(json['notifications'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'biometricEnabled': biometricEnabled,
      'themeMode': themeMode,
      'security': security.toJson(),
      'notifications': notifications.toJson(),
    };
  }

  UserSettings copyWith({
    bool? biometricEnabled,
    String? themeMode,
    SecuritySettings? security,
    NotificationSettings? notifications,
  }) {
    return UserSettings(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      themeMode: themeMode ?? this.themeMode,
      security: security ?? this.security,
      notifications: notifications ?? this.notifications,
    );
  }
}
