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
```

---

## ▶️ Getting Started

### Prerequisites

Make sure you have the following installed:

- Flutter SDK (3.x or later)
- Android Studio or VS Code
- An emulator or physical device

Check Flutter installation:
flutter --version

---

### 1. Clone the repository

git clone https://github.com/mphephuSamuel/labnet-guardian.git  
cd labnet-guardian-frontend

---

### 2. Install dependencies

flutter pub get

---

### 3. Run the app

flutter run

---

### 4. Build APK (optional)

flutter build apk

---

## 🤝 Collaboration Guide

We follow a simple Git workflow to work as a team.

### Branches

- main → stable version of the app
- development → active development branch

---

### How to work on a feature

1. Pull the latest changes
   git checkout development  
   git pull

2. Create a new branch for your feature  
   Example:
   git checkout -b feature/login-ui

(Use names like: feature/dashboard-ui, feature/devices-screen)

3. Work on your feature and commit changes
   git add .  
   git commit -m "feat: add login UI"

4. Push your branch to GitHub
   git push origin feature/login-ui

5. Create a Pull Request (PR) on GitHub

- Go to the repository
- Click "Compare & pull request"
- Select base: development
- Request review

6. After merge

- Go back to development
  git checkout development  
  git pull

---

### Important Rules

- Do NOT push directly to main
- Do NOT push directly to development
- Always create a feature branch
- Always pull latest changes before starting
- Use clear commit messages (feat:, fix:, etc.)

---

### Branches

## 🔄 Git Workflow Diagram

```mermaid
graph TD
    A[main (stable)] --> B[development]
    B --> C[feature/login-ui]
    B --> D[feature/dashboard-ui]
    B --> E[feature/devices-screen]

    C --> B
    D --> B
    E --> B

    B --> A

## 📸 Screens

Screens will be added here (Dashboard, Devices, Alerts, etc.)

---

## 🔧 Current Status

- UI development in progress
- Using mock data (no backend yet)
- Backend & Firebase integration coming next

---

## 👥 Team

- Tshifhiwa Mphephu – Project Lead & Backend Developer
- Jabulile Lubisi – Frontend Lead (UI/UX)
- Sibekezelo Khumalo – Security & Anomaly Engineer
- Luyanda Kubheka – QA & Documentation
- Blessing Masuku – Integration & QA

---

## 📄 License

This project is developed for academic purposes at the University of Mpumalanga.

---

## 💡 Future Improvements

- Firebase Authentication & Notifications
- Real-time data integration
- Backend API connection
- Advanced anomaly detection visualization
- Performance optimization

---

## ⭐ Notes

This project is part of the BICT421 Mini Project (LabNet Guardian) and demonstrates practical implementation of network monitoring and security concepts.
```
