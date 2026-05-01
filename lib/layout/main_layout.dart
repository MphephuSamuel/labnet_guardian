import 'package:flutter/material.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/custom_bottom_nav_bar.dart';
import '../widgets/common/custom_drawer.dart';
import '../screens/dashboard_screen.dart';
import '../screens/devices_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/history_screen.dart';
import '../screens/ai_assistant_screen.dart';
import '../screens/biometric_screen.dart';
import '../screens/authentication_screen.dart';
import '../screens/login_screen.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 1});

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const DevicesScreen(),
    const SecurityAlertsScreen(),
    const ActivityHistoryScreen(),
    const AiAssistantScreen(),
  ];

  void jumpTo(int index) { // make sure this method exists
    setState(() {
      _currentIndex = index;
    });
  }
  
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
