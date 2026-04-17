import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  String apiKey = '';
  final envFile = File('.env');
  if (await envFile.exists()) {
    final lines = await envFile.readAsLines();
    for (var line in lines) {
      if (line.trim().startsWith('GEMINI_API_KEY=')) {
        apiKey = line.split('=')[1].trim();
        if (apiKey.startsWith('"') && apiKey.endsWith('"')) apiKey = apiKey.substring(1, apiKey.length - 1);
      }
    }
  }

  if (apiKey.isEmpty) { print("Key empty!"); return; }

  final httpClient = HttpClient();
  
  Future<void> testModel(String model) async {
    try {
      final request = await httpClient.postUrl(Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/\$model:generateContent?key=" + apiKey));
      request.headers.set("Content-Type", "application/json");
      request.write(jsonEncode({
          "contents": [{"role": "user", "parts": [{"text": "Hello"}]}]
      }));
      final response = await request.close();
      final bodyStr = await response.transform(utf8.decoder).join();
      print("Model: \$model => STATUS: \${response.statusCode}");
      if (response.statusCode != 200) {
        print(bodyStr.substring(0, 100).replaceAll('\\n', ' '));
      } else {
        print("SUCCESS");
      }
    } catch(e) {
      print("Error natively: \$e");
    }
  }

  print("Testing gemini-flash-latest...");
  await testModel("gemini-flash-latest");
  print("");
  print("Testing gemini-2.5-flash...");
  await testModel("gemini-2.5-flash");
  
  httpClient.close();
}
