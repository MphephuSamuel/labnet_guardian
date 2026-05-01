import 'package:flutter/material.dart';
import '../widgets/ai_assistant/chat_bubble.dart';
import '../widgets/ai_assistant/quick_action_card.dart';
import '../widgets/ai_assistant/chat_input_field.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hi! I\'m LabNet AI Assistant. I can help you with network monitoring, device management, security alerts, and more. How can I assist you today?',
      'time': '18:19',
      'isBot': true,
    }
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final now = TimeOfDay.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({
        'text': text,
        'time': timeString,
        'isBot': false,
      });
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI thinking and responding
    Future.delayed(const Duration(seconds: 1), () {
      String responseText = "I'm a dummy assistant for now. But I see you're asking about: '$text'. I'll be able to help with this soon!";
      
      if (text.toLowerCase().contains('network status')) {
        responseText = "The network is currently stable. Total bandwidth usage is at 45%. No major outages detected.";
      } else if (text.toLowerCase().contains('device issue')) {
        responseText = "I'm monitoring 2 suspicious devices. TABLET-ENG-015 has unusual high traffic, and IOT-SENSOR-01 is communicating with an unknown external IP.";
      } else if (text.toLowerCase().contains('security overview')) {
        responseText = "Your network security score is 85/100. There are 2 active alerts requiring your attention in the Alerts tab.";
      } else if (text.toLowerCase().contains('traffic stats')) {
        responseText = "Today's peak traffic was 1.2 GB/s at 14:00. Average throughput is currently 350 MB/s.";
      }

      setState(() {
        _messages.add({
          'text': responseText,
          'time': timeString,
          'isBot': true,
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _messages.length + 1, // +1 for the Quick Actions which we'll insert after the first message
            itemBuilder: (context, index) {
              if (index == 1 && _messages.length == 1) {
                // Show Quick Actions only when there's just the initial greeting
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          onTap: () => _sendMessage('Show me the network status'),
                        ),
                        QuickActionCard(
                          title: 'Device Issues',
                          icon: Icons.phone_android,
                          iconColor: Theme.of(context).iconTheme.color ?? Colors.black87,
                          onTap: () => _sendMessage('Are there any device issues?'),
                        ),
                        QuickActionCard(
                          title: 'Security Overview',
                          icon: Icons.lock_outline,
                          iconColor: Colors.orange,
                          onTap: () => _sendMessage('Give me a security overview'),
                        ),
                        QuickActionCard(
                          title: 'Traffic Stats',
                          icon: Icons.bar_chart,
                          iconColor: Colors.green,
                          onTap: () => _sendMessage('Show me the traffic stats'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }

              // Adjust index to skip the Quick Actions widget position if it's shown
              final messageIndex = (index > 0 && _messages.length == 1) ? index - 1 : index;
              
              if (messageIndex >= _messages.length) return const SizedBox.shrink();

              final msg = _messages[messageIndex];
              return ChatBubble(
                text: msg['text'],
                time: msg['time'],
                isBot: msg['isBot'],
              );
            },
          ),
        ),
        ChatInputField(
          controller: _messageController,
          onSend: () => _sendMessage(_messageController.text),
        ),
      ],
    );
  }
}
