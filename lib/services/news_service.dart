import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

class NewsService {
  static const _base = 'https://newsapi.org/v2';
  final int pageSize;
  static const _ttlSeconds = 600; // 10 minutes

  NewsService({this.pageSize = 10});

  String get _key {
    final k = dotenv.env['NEWS_API_KEY'] ?? dotenv.env['API_KEY'] ?? '';
    if (k.isEmpty) {
      throw Exception('NEWS_API_KEY not set in assets/env');
    }
    return k;
  }

  String _cacheKey(int page) => 'news_page_$page';

  Future<List<Article>> fetchNews({required int page}) async {
    final prefs = await SharedPreferences.getInstance();
    final ck = _cacheKey(page);
    final cachedStr = prefs.getString(ck);
    if (cachedStr != null) {
      final obj = jsonDecode(cachedStr) as Map<String, dynamic>;
      final ts = (obj['ts'] as int?) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (now - ts <= _ttlSeconds) {
        final items = (obj['data'] as List).cast<Map<String, dynamic>>();
        return items.map(Article.fromMap).toList();
      }
    }

    final uri = Uri.parse(
      '$_base/top-headlines?country=us&category=business&page=$page&pageSize=$pageSize&apiKey=$_key',
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('NewsAPI error (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final List items = (data['articles'] as List? ?? []);
    final articles =
        items.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();

    // cache
    final payload = {
      'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'data': articles.map((e) => e.toMap()).toList(),
    };
    await prefs.setString(ck, jsonEncode(payload));
    return articles;
  }
}
