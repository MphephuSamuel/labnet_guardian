import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../utils/colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;
    
    return Scaffold(
      backgroundColor: AppColors.getBgColor(isDark),
      appBar: AppBar(
        backgroundColor: AppColors.getBgColor(isDark),
        elevation: 0,
        leading: BackButton(color: AppColors.getTextPrimary(isDark)),
        centerTitle: true,
        title: Text(
          'Help & Support',
          style: TextStyle(
            color: AppColors.getTextPrimary(isDark),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => theme.toggleTheme(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : const Color(0xFFE8E8F4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDark ? Icons.wb_sunny : Icons.dark_mode_outlined,
                  color: AppColors.getTextPrimary(isDark),
                  size: 20,
                ),
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
            Text(
              'Resources',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: 16),
            _buildResourcesGrid(isDark),
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
    
    return GestureDetector(
      onTap: () async {
        if (label == 'Email') {
          final email = Uri.parse('mailto:labnet@gmail.com');
          if (await canLaunchUrl(email)) {
            await launchUrl(email);
          }
        } else if (label == 'Call') {
          final phone = Uri.parse('tel:0116000000');
          if (await canLaunchUrl(phone)) {
            await launchUrl(phone);
          }
        }
      },
      child: Column(
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
      ),
    );
  }

  Widget _buildResourcesGrid(bool isDark) {
    final resources = [
      _ResourceItem(
        icon: Icons.videocam_outlined,
        iconBgColor: const Color(0xFFFDE8F0),
        iconColor: const Color(0xFFE84FA0),
        title: 'Video Tutorials',
        description: 'Step-by-step video walkthroughs',
        url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      ),
      _ResourceItem(
        icon: Icons.help_outline,
        iconBgColor: const Color(0xFFE6F6F4),
        iconColor: const Color(0xFF2BAE9E),
        title: 'Troubleshooting',
        description: 'Common issues and solutions',
        url: 'https://labnet-support.com/troubleshooting',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 0.75,
      children: resources.map((item) => _buildResourceCard(item, isDark)).toList(),
    );
  }

  Widget _buildResourceCard(_ResourceItem item, bool isDark) {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(item.url);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(isDark),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
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
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(isDark),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.description,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(isDark),
                height: 1.4,
              ),
            ),
          ],
        ),
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
  final String url;

  const _ResourceItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.url,
  });
}
