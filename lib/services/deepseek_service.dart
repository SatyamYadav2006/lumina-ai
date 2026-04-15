import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';
import '../models/horoscope_model.dart';

class DeepSeekService {
  String get _apiKey => dotenv.env['DEEPSEEK_API_KEY'] ?? '';

  final String _endpoint = "https://api.deepseek.com/chat/completions";

  // Generate Daily Horoscope
  Future<HoroscopeModel> generateDailyHoroscope(UserModel user, DateTime date) async {
    String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final prompt = """
Generate a highly detailed, deeply mystical, and expansive daily horoscope for today ($formattedDate).

User Details:
Name: ${user.name}
Zodiac: ${user.zodiacSign}

Critical Instructions:
1. YOU MUST WRITE EXTREMELY LONG PARAGRAPHS. The 'dailySummary', 'career', 'love', 'health', and 'finance' JSON values must EACH be a massive block of text containing at least 80 to 100 words per section. Absolutely no short summaries. If you write less than 4 full sentences for a section, you have failed.
2. For 'luckyTime', you must literally return the exact string: "All Day" so the auspicious moment spans the entire date.
3. Ensure 'luckyNumber' and 'luckyColor' are drastically randomized.
4. 'dos' and 'donts' should be deep psychological and practical directives.

Return ONLY valid JSON in this format:
{
  "dailySummary": "...",
  "career": "...",
  "love": "...",
  "health": "...",
  "finance": "...",
  "mood": "...",
  "luckyNumber": "...",
  "luckyColor": "...",
  "luckyTime": "...",
  "dos": ["...", "..."],
  "donts": ["...", "..."]
}
""";

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey"
        },
        body: jsonEncode({
          "model": "deepseek-chat",
          "response_format": {"type": "json_object"},
          "messages": [
            {"role": "system", "content": "You are a master astrologer capable of writing deep, mystical, and profoundly insightful daily horoscopes."},
            {"role": "user", "content": prompt}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'];

        // Clean JSON in case of markdown formatting
        content = content.replaceAll("```json", "").replaceAll("```", "").trim();

        final Map<String, dynamic> output = jsonDecode(content);

        return HoroscopeModel(
          id: formattedDate,
          date: date,
          zodiacSign: user.zodiacSign,
          dailySummary: output['dailySummary'] ?? '',
          career: output['career'] ?? '',
          love: output['love'] ?? '',
          health: output['health'] ?? '',
          finance: output['finance'] ?? '',
          mood: output['mood'] ?? '',
          luckyNumber: output['luckyNumber'] ?? '',
          luckyColor: output['luckyColor'] ?? '',
          luckyTime: output['luckyTime'] ?? '',
          dos: List<String>.from(output['dos'] ?? []),
          donts: List<String>.from(output['donts'] ?? []),
        );
      } else {
        throw Exception("DeepSeek error: \${response.statusCode} - \${response.body}");
      }
    } catch (e) {
      throw Exception("DeepSeek API Error: \$e");
    }
  }

  // Chatbot
  Future<String> sendChatMessage(
      List<Map<String, String>> messageHistory, UserModel user) async {
    final systemPrompt = """
You are Lumina, a mystical and friendly AI Oracle chatbot.
The user you are speaking to is ${user.name}, who is a ${user.zodiacSign}.
Respond with deep astrological insight, empathy, and cosmic wisdom.

CRITICAL RULES:
1. You MUST reply in the EXACT SAME language the user speaks to you in. If they type English, reply strictly in English. If they type Hindi, reply strictly in Hindi. This is mandatory.
2. DO NOT USE ANY emojis, asterisks (*), hashtags, or special symbols. Output plain text only so a text-to-speech engine can read your reply flawlessly.
""";

    List<Map<String, String>> apiMessages = [
      {"role": "system", "content": systemPrompt}
    ];

    for (var msg in messageHistory) {
      apiMessages.add({"role": msg['role']!, "content": msg['content']!});
    }

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey"
        },
        body: jsonEncode({
          "model": "deepseek-chat",
          "messages": apiMessages
        }),
      );

      if (response.statusCode == 200) {
         final data = jsonDecode(response.body);
         return data['choices'][0]['message']['content'];
      } else {
        throw Exception("DeepSeek Chatbot error: \${response.body}");
      }
    } catch (e) {
      throw Exception("DeepSeek API Error: \$e");
    }
  }
}
