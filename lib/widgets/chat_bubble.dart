import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isPlaying;
  final VoidCallback? onPlayAudio;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.isPlaying = false,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    Color bubbleColor = isUser
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surface;
    Color textColor = isUser
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            if (!isUser && onPlayAudio != null)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(isPlaying ? Icons.stop_circle_outlined : Icons.volume_up, color: textColor.withOpacity(0.7), size: 24),
                  onPressed: onPlayAudio,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              )
          ],
        ),
      ),
    );
  }
}
