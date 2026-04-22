import 'package:flutter/material.dart';
import '../widgets/ai_assistant/chat_bubble.dart';
import '../widgets/ai_assistant/quick_action_card.dart';
import '../widgets/ai_assistant/chat_input_field.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void showServiceInProgress() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This service is still in progress.'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'AI Assistant',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              const ChatBubble(
                text: 'Hi! I\'m LabNet AI Assistant. I can help you with network monitoring, device management, security alerts, and more. How can I assist you today?',
                time: '18:19',
                isBot: true,
              ),
              const SizedBox(height: 16),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.2,
                children: [
                  QuickActionCard(
                    title: 'Network Status',
                    icon: Icons.language,
                    iconColor: Colors.blue,
                    onTap: showServiceInProgress,
                  ),
                  QuickActionCard(
                    title: 'Device Issues',
                    icon: Icons.phone_android,
                    iconColor: Theme.of(context).iconTheme.color ?? Colors.black87,
                    onTap: showServiceInProgress,
                  ),
                  QuickActionCard(
                    title: 'Security Overview',
                    icon: Icons.lock_outline,
                    iconColor: Colors.orange,
                    onTap: showServiceInProgress,
                  ),
                  QuickActionCard(
                    title: 'Traffic Stats',
                    icon: Icons.bar_chart,
                    iconColor: Colors.green,
                    onTap: showServiceInProgress,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        ChatInputField(
          onSend: showServiceInProgress,
        ),
      ],
    );
  }
}
