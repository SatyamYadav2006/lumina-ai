import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/app_state_provider.dart';
import '../services/gemini_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/celestial_background.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final GeminiService _aiService = GeminiService();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  late FlutterTts flutterTts;
  String? _playingText;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    
    flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _playingText = null);
      }
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (_playingText == text) {
      await flutterTts.stop();
      if (mounted) setState(() => _playingText = null);
      return;
    }

    await flutterTts.stop();
    if (mounted) setState(() => _playingText = text);

    // Force strict Hindi (hi-IN) engine universally for all strings to natively guarantee a heavy Indian accent.
    String targetLocale = "hi-IN";

    await flutterTts.setLanguage(targetLocale);

    // Actively scan and bind to High-Quality Neural/Network voices natively if available!
    // This entirely eliminates the robotic "offline" chopped accent.
    if (!kIsWeb) {
      try {
        List<dynamic> voices = await flutterTts.getVoices;
        for (dynamic voice in voices) {
          String name = voice["name"].toString().toLowerCase();
          String locale = voice["locale"].toString();
          if (locale == targetLocale && (name.contains("network") || name.contains("neural"))) {
            await flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
            break;
          }
        }
      } catch (e) {
        debugPrint("TTS Neural Voice Binding error: $e");
      }
    }

    // Rely explicitly on OS default speech rates! Forcing manual multipliers severely distorts complex Indian accents natively.
    if (kIsWeb) {
       await flutterTts.setSpeechRate(1.0);
    } else {
       // Reset back to absolute standard native speed (usually 0.5 internally automatically).
       await flutterTts.setSpeechRate(0.5); 
    }

    await flutterTts.setPitch(1.0);

    await flutterTts.speak(text);
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final text = _messageController.text.trim();
    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final user = Provider.of<AppStateProvider>(context, listen: false).currentUserData;
      if (user != null) {
        final response = await _aiService.sendChatMessage(_messages, user);
        if (mounted) {
          setState(() {
            _messages.add({"role": "assistant", "content": response});
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lumina: ${e.toString().replaceAll("Exception: ", "")}', style: const TextStyle(color: Colors.white)), duration: const Duration(seconds: 5), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Lumina Chat", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4.0, fontSize: 16)),
        centerTitle: true,
        backgroundColor: isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.7),
        elevation: 0,
      ),
      body: CelestialBackground(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + kToolbarHeight + 16, 16, 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return ChatBubble(
                    text: msg["content"]!,
                    isUser: msg["role"] == "user",
                    isPlaying: _playingText == msg["content"],
                    onPlayAudio: msg["role"] == "user" ? null : () => _speak(msg["content"]!),
                  ).animate().fade().slideY(begin: 0.1);
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const CircularProgressIndicator().animate(onPlay: (c) => c.repeat()).shimmer(),
              ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
                border: Border(top: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1))),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Ask Lumina anything...",
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                           BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), blurRadius: 12)
                        ]
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.auto_awesome, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
