import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const _openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const _model = 'gpt-4o-mini';

  static Future<List<String>> generateReplies(String context, String mode, bool premium) async {
    if (_openAiApiKey.isEmpty) {
      return _localFallback(context, mode);
    }

    final prompt = '''You are an expert Indian Gen-Z texting assistant.
Generate 5 realistic Hindi/Hinglish chat replies for a $mode response style.
Keep replies short, emotional, natural, and modern. Use emojis naturally.
Do not sound robotic. Return the answers as separate lines or bullet points.''';

    final body = {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': prompt},
        {'role': 'user', 'content': context},
      ],
      'temperature': premium ? 0.95 : 0.76,
      'max_tokens': 400,
    };

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openAiApiKey',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      return _localFallback(context, mode);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final text = (json['choices'] as List).first['message']['content'] as String;
    return text
        .split(RegExp(r"\n+"))
        .map((line) => line.replaceAll(RegExp(r'^[0-9\-\.\)]+\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  static List<String> _localFallback(String context, String mode) {
    return [
      'Bas itna bol, "Aise hi teri baat ka replay milta hai toh din ban jaata hai 😌💕"',
      'Hahaha, yeh chat ekdum mast hai. Thoda swag dikhana padega ab 😎',
      'Yeh toh full desi vibe hain. Tu bol, main teri line ka reply ready kar deta hu 😏',
      'Cute mode on: "Tu aise hi hasegi toh dil chillayega 💜"',
      'Late night chat ho toh isse better kya? "Sona nahi hai, teri baat chalti rehni chahiye 🌙✨"',
    ];
  }
}
