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
  
  try {
    final request = await httpClient.getUrl(Uri.parse("https://generativelanguage.googleapis.com/v1beta/models?key=" + apiKey));
    final response = await request.close();
    final bodyStr = await response.transform(utf8.decoder).join();
    
    final json = jsonDecode(bodyStr);
    print("Found \${json['models'].length} models");
    for(var m in json['models']) {
        if (m['name'].toString().contains("flash")) {
            print(m['name']);
        }
    }
    print("--- 2.0 / 2.5 series ---");
    for(var m in json['models']) {
        if (m['name'].toString().contains("2.5") || m['name'].toString().contains("3.0")) {
            print(m['name']);
        }
    }
    
  } catch (e) {
    print("FAILED_" + e.toString());
  } finally {
    httpClient.close();
  }
}
