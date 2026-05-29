import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isBot;

  const ChatBubble({
    super.key,
    required this.text,
    required this.time,
    this.isBot = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isBot
        ? Theme.of(context).cardColor
        : (isDark ? const Color(0xFF7B2FBE) : const Color(0xFFF0E6FF));

    final textColor = isBot
        ? (isDark ? Colors.white : Colors.black87)
        : (isDark ? Colors.white : const Color(0xFF4A154B));

    final timeColor = isBot
        ? Colors.grey.shade500
        : (isDark ? Colors.white70 : Colors.grey.shade600);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 24,
              ),
            )
          else
            const SizedBox(width: 48), // Left spacer for user messages

          Expanded(
            child: Column(
              crossAxisAlignment: isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isBot ? 0 : 16),
                      bottomRight: Radius.circular(isBot ? 16 : 0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormattedText(
                        text,
                        TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: timeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (!isBot)
            Container(
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Colors.purple.shade800,
                size: 24,
              ),
            )
          else
            const SizedBox(width: 48), // Right spacer for bot messages
        ],
      ),
    );
  }

  Widget _buildFormattedText(String text, TextStyle baseStyle) {
    final lines = text.split('\n');
    final List<Widget> lineWidgets = [];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        if (i < lines.length - 1) {
          lineWidgets.add(const SizedBox(height: 8));
        }
        continue;
      }

      // Check if it is a heading
      final isHeading = line.trim().startsWith('#');
      // Check if it is a bullet point
      final isBullet = line.trim().startsWith('- ') ||
          line.trim().startsWith('* ') ||
          line.trim().startsWith('• ');

      String cleanLine = line;
      TextStyle currentStyle = baseStyle;

      if (isHeading) {
        // Strip leading # symbols and spaces
        cleanLine = line.trim().replaceFirst(RegExp(r'^#+\s*'), '');
        currentStyle = baseStyle.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: baseStyle.fontSize! + 2,
        );
      } else if (isBullet) {
        // Strip the bullet marker
        cleanLine = line.trim().substring(2);
      }

      // Parse bold elements in the line
      final List<InlineSpan> spans = [];
      final RegExp regExp = RegExp(r'\*\*(.*?)\*\*');
      int start = 0;

      for (final Match match in regExp.allMatches(cleanLine)) {
        if (match.start > start) {
          spans.add(TextSpan(
            text: cleanLine.substring(start, match.start),
          ));
        }
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
        start = match.end;
      }

      if (start < cleanLine.length) {
        spans.add(TextSpan(
          text: cleanLine.substring(start),
        ));
      }

      if (isBullet) {
        lineWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: currentStyle.copyWith(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: spans),
                    style: currentStyle,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        lineWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text.rich(
              TextSpan(children: spans),
              style: currentStyle,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lineWidgets,
    );
  }
}
