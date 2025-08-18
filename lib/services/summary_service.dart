import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

class SummaryService {
  static const _cachePrefix = 'summary_';
  static const _model = 'gpt-4o-mini'; // lightweight & cheap; adjust if needed

  String get _key {
    final k = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (k.isEmpty) throw Exception('OPENAI_API_KEY not set in assets/env');
    return k;
  }

  Future<String> getBulletSummary(Article a) async {
    final prefs = await SharedPreferences.getInstance();
    final ck = '$_cachePrefix${a.id}';
    final cached = prefs.getString(ck);
    if (cached != null && cached.isNotEmpty) return cached;

    final prompt = '''
Create exactly 6 concise bullet points (no extra text before/after) summarizing this business news for busy professionals. Each bullet short, high-signal. Total 60–100 words.

Title: ${a.title}
Description: ${a.description}
Source: ${a.source}
Published: ${a.publishedAt.toIso8601String()}
URL: ${a.url}
''';

    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Authorization': 'Bearer $_key',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'model': _model,
      'messages': [
        {'role': 'system', 'content': 'You are a concise business news summarizer.'},
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.3,
      'max_tokens': 220,
    });

    final res = await http.post(uri, headers: headers, body: body);
    if (res.statusCode != 200) {
      throw Exception('OpenAI error (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final content = (data['choices']?[0]?['message']?['content'] ?? '').toString();

    // normalize to clean bullet list
    final cleaned = content
        .trim()
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .map((l) => l.replaceFirst(RegExp(r'^[-•\*\d\.\s]+'), '• ').trim())
        .join('\n');

    await prefs.setString(ck, cleaned);
    return cleaned;
  }
}
