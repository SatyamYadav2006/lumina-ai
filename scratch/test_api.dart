import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  String apiKey = 'PASTE_YOUR_KEY_HERE';

  final url = Uri.parse("https://api.deepseek.com/v1/chat/completions");
  final httpClient = HttpClient();

  try {
    final request = await httpClient.postUrl(url);
    request.headers.set("Content-Type", "application/json");
    request.headers.set("Authorization", "Bearer $apiKey");

    request.write(jsonEncode({
      "model": "deepseek-chat",
      "messages": [
        {"role": "user", "content": "Hello"}
      ]
    }));

    final response = await request.close();
    print("STATUS: ${response.statusCode}");

    final body = await response.transform(utf8.decoder).join();
    print("BODY: $body");

  } catch (e) {
    print("ERROR: $e");
  } finally {
    httpClient.close();
  }
}