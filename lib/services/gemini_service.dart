import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';
import '../models/horoscope_model.dart';

class GeminiService {
  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  String get _endpoint => 
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$_apiKey";

  // ✅ DAILY HOROSCOPE
  Future<HoroscopeModel> generateDailyHoroscope(
      UserModel user, DateTime date) async {

    String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final prompt = """
Generate a short daily horoscope for today ($formattedDate).

User:
Name: ${user.name}
Zodiac: ${user.zodiacSign}

Return strictly JSON format:
{
  "dailySummary": "",
  "career": "",
  "love": "",
  "health": "",
  "finance": "",
  "mood": "",
  "luckyNumber": "",
  "luckyColor": "",
  "luckyTime": "",
  "dos": ["", ""],
  "donts": ["", ""]
}
""";

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "system_instruction": {
            "parts": {"text": "You are an expert astrologer. Return only valid JSON."}
          },
          "contents": [
            {
              "role": "user",
              "parts": [{"text": prompt}]
            }
          ],
          "generationConfig": {
            "responseMimeType": "application/json"
          }
        }),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['candidates'][0]['content']['parts'][0]['text'];
        
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
        throw Exception("Horoscope API Error: ${response.body}");
      }
    } catch (e) {
      throw Exception("Horoscope Error: $e");
    }
  }

  // ✅ CHATBOT
  Future<String> sendChatMessage(
      List<Map<String, String>> messageHistory, UserModel user) async {

    final systemPrompt = """
You are Lumina AI astrologer.

User:
Name: ${user.name}
Zodiac: ${user.zodiacSign}

Give short answer (2-3 lines). Reply in the exact same language the user speaks.
""";

    List<Map<String, dynamic>> contents = [];

    for (var msg in messageHistory) {
      // Gemini expects "user" or "model" instead of "assistant"
      String role = msg['role'] == 'user' ? 'user' : 'model';
      contents.add({
        "role": role,
        "parts": [{"text": msg['content']!}]
      });
    }

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "system_instruction": {
            "parts": {"text": systemPrompt}
          },
          "contents": contents,
        }),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception("Chat API Error: ${response.body}");
      }
    } catch (e) {
      throw Exception("Chat Error: $e");
    }
  }
}
