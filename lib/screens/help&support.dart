import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEEEF8),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8F4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.dark_mode_outlined,
                color: Colors.black54,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildImmediateHelpCard(),
            const SizedBox(height: 28),
            const Text(
              'Resources',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildResourcesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildImmediateHelpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7B4FD4),
            Color(0xFFB94FC8),
            Color(0xFFE84FA0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need Immediate Help?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContactButton(Icons.chat_bubble_outline, 'Live Chat'),
              _buildContactButton(Icons.mail_outline, 'Email'),
              _buildContactButton(Icons.phone_outlined, 'Call'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(IconData icon, String label) {
    String? info;
    if (label == 'Email') {
      info = 'labnet@gmail.com';
    } else if (label == 'Call') {
      info = '0116000000';
    }
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (info != null)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              info,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResourcesGrid() {
    final resources = [
      _ResourceItem(
        icon: Icons.menu_book_outlined,
        iconBgColor: const Color(0xFFEDE8FB),
        iconColor: const Color(0xFF7B4FD4),
        title: 'User Guide',
        description: 'Complete documentation for LabNet',
      ),
      _ResourceItem(
        icon: Icons.videocam_outlined,
        iconBgColor: const Color(0xFFFDE8F0),
        iconColor: const Color(0xFFE84FA0),
        title: 'Video Tutorials',
        description: 'Step-by-step video walkthroughs',
      ),
      _ResourceItem(
        icon: Icons.description_outlined,
        iconBgColor: const Color(0xFFE8EDFB),
        iconColor: const Color(0xFF4F6BD4),
        title: 'API\nDocumentation',
        description: 'Developer reference and API docs',
      ),
      _ResourceItem(
        icon: Icons.help_outline,
        iconBgColor: const Color(0xFFE6F6F4),
        iconColor: const Color(0xFF2BAE9E),
        title: 'Troubleshooting',
        description: 'Common issues and solutions',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 0.75,
      children: resources.map(_buildResourceCard).toList(),
    );
  }

  Widget _buildResourceCard(_ResourceItem item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black45,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceItem {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String description;

  const _ResourceItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}
