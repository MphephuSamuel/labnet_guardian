# LabNet Guardian (Frontend)

## 📱 Overview

LabNet Guardian is a mobile application designed to help university administrators monitor network activity in real-time.  
The system provides visibility into connected devices, detects suspicious behavior, and delivers alerts through a simple and modern mobile interface.

This repository contains the **Flutter frontend** of the system.

---

## 🚀 Features

- 🔐 User Authentication (Login & Biometrics – planned)
- 📊 Dashboard with real-time network statistics
- 💻 Connected Devices Monitoring (IP, MAC, usage)
- 🚨 Security Alerts & Notifications
- 🕓 Activity History Tracking
- 📈 Analytics & Reports
- 🔎 Advanced Search
- 🤖 AI Assistant (planned)
- ⚙️ System Settings & Configuration

---

## 🛠️ Tech Stack

- Flutter (Dart)
- Firebase (planned)
- Node.js (planned)
- Python (planned)

---

## 📂 Project Structure

```bash
lib/
├── main.dart
├── screens/
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── devices_screen.dart
│   ├── alerts_screen.dart
│   ├── history_screen.dart
│   ├── analytics_screen.dart
│   ├── settings_screen.dart
│   ├── profile_screen.dart
│   ├── search_screen.dart
│   ├── support_screen.dart
│   └── ai_assistant_screen.dart
│
├── widgets/
│   ├── dashboard/
│   │   ├── dashboard_header.dart
│   │   ├── stat_card.dart
│   │   └── activity_banner.dart
│   ├── devices/
│   │   ├── device_card.dart
│   │   └── device_filter.dart
│   ├── alerts/
│   │   ├── alert_card.dart
│   │   └── alert_badge.dart
│   ├── history/
│   │   └── history_item.dart
│   ├── analytics/
│   │   ├── chart_widget.dart
│   │   └── stats_card.dart
│   ├── settings/
│   │   └── settings_tile.dart
│   └── common/
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── loading_indicator.dart
│       ├── app_drawer.dart
│       └── bottom_nav_bar.dart
│
├── models/
│   ├── device.dart
│   ├── alert.dart
│   ├── user.dart
│   └── history.dart
│
├── services/
│   ├── device_service.dart
│   ├── alert_service.dart
│   ├── auth_service.dart
│   └── analytics_service.dart
│
├── utils/
│   ├── colors.dart
│   ├── constants.dart
│   └── helpers.dart