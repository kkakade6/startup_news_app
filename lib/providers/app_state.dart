import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

class AppState extends ChangeNotifier {
  static const _bookmarksKey = 'bookmarks';
  static const _progressKey = 'progress_date_count';
  static const _streakKey = 'streak_days';
  static const _lastActiveDateKey = 'last_active_date';

  final List<Article> bookmarks = [];
  String searchQuery = '';
  String? filterSource;

  int todayCount = 0;
  int streakDays = 0;
  DateTime? lastActive;

  AppState() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // bookmarks
    final b = prefs.getString(_bookmarksKey);
    if (b != null) {
      final list = (jsonDecode(b) as List).cast<Map<String, dynamic>>();
      bookmarks.addAll(list.map(Article.fromMap));
    }

    // progress
    final pc = prefs.getString(_progressKey);
    if (pc != null) {
      final obj = jsonDecode(pc) as Map<String, dynamic>;
      final date = obj['date']?.toString();
      final cnt = (obj['count'] as int?) ?? 0;
      final todayStr = _dateStr(DateTime.now());
      if (date == todayStr) todayCount = cnt;
    }

    // streak
    streakDays = prefs.getInt(_streakKey) ?? 0;
    final last = prefs.getString(_lastActiveDateKey);
    if (last != null) lastActive = DateTime.tryParse(last);

    notifyListeners();
  }

  List<Article> applyFilters(List<Article> src) {
    Iterable<Article> res = src;
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      res = res.where((a) =>
          a.title.toLowerCase().contains(q) ||
          a.description.toLowerCase().contains(q) ||
          a.source.toLowerCase().contains(q));
    }
    if (filterSource != null && filterSource!.isNotEmpty) {
      res = res.where((a) => a.source == filterSource);
    }
    return res.toList();
  }

  Future<void> toggleBookmark(Article a) async {
    final idx = bookmarks.indexWhere((x) => x.id == a.id);
    if (idx >= 0) {
      bookmarks.removeAt(idx);
    } else {
      bookmarks.add(a);
    }
    await _persistBookmarks();
    notifyListeners();
  }

  bool isBookmarked(Article a) =>
      bookmarks.any((x) => x.id == a.id);

  Future<void> _persistBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _bookmarksKey,
      jsonEncode(bookmarks.map((e) => e.toMap()).toList()),
    );
  }

  Future<void> incrementProgress({int dailyGoal = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateStr(DateTime.now());
    final pc = prefs.getString(_progressKey);
    int count = 0;
    String savedDate = today;

    if (pc != null) {
      final obj = jsonDecode(pc) as Map<String, dynamic>;
      savedDate = (obj['date'] ?? today).toString();
      count = (obj['count'] as int?) ?? 0;
      if (savedDate != today) count = 0;
    }
    count += 1;
    todayCount = count;
    await prefs.setString(_progressKey, jsonEncode({'date': today, 'count': count}));

    // streak
    _updateStreakOnRead(prefs);

    notifyListeners();
  }

  Future<void> _updateStreakOnRead(SharedPreferences prefs) async {
    final now = DateTime.now();
    final today = _dateStr(now);
    final lastStr = prefs.getString(_lastActiveDateKey);
    if (lastStr == null) {
      streakDays = 1;
    } else {
      final last = DateTime.tryParse(lastStr);
      if (last != null) {
        final diff = now.difference(DateTime(last.year, last.month, last.day)).inDays;
        if (diff == 1) {
          streakDays += 1;
        } else if (diff > 1) {
          streakDays = 1;
        }
      }
    }
    await prefs.setString(_lastActiveDateKey, now.toIso8601String());
    await prefs.setInt(_streakKey, streakDays);
  }

  static String _dateStr(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
