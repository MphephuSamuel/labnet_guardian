import 'package:flutter/material.dart';
import '../widgets/ai_assistant/chat_bubble.dart';
import '../widgets/ai_assistant/quick_action_card.dart';
import '../widgets/ai_assistant/chat_input_field.dart';
import '../services/ai_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiService _aiService = AiService();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hi! I\'m LabNet AI Assistant. I can help you with network monitoring, device management, security alerts, and more. How can I assist you today?',
      'time': '18:19',
      'isBot': true,
    }
  ];

  void _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final now = TimeOfDay.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final prompt = text;

    setState(() {
      _messages.add({
        'text': prompt,
        'time': timeString,
        'isBot': false,
      });
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Add placeholder message for the bot's response
    final thinkingMessageIndex = _messages.length;
    setState(() {
      _messages.add({
        'text': 'Thinking...',
        'time': timeString,
        'isBot': true,
      });
    });
    _scrollToBottom();

    try {
      // Call real backend API
      final response = await _aiService.queryAI(
        prompt,
        _messages.sublist(0, thinkingMessageIndex),
      );
      final String reply = response['reply'] ?? 'No response returned';

      if (mounted) {
        setState(() {
          _messages[thinkingMessageIndex]['text'] = reply;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages[thinkingMessageIndex]['text'] =
              'Error: Failed to connect to AI Assistant. ($e)';
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
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
