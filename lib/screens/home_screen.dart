import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/app_state.dart';
import '../services/news_service.dart';
import '../widgets/news_card.dart';
import 'bookmarks_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _page = PageController();
  final NewsService _service = NewsService(pageSize: 10);
  final List<Article> _articles = [];

  bool _initialLoading = true;
  bool _loadingMore = false;
  int _pageNum = 1;
  int _currentIndex = 0;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
    _page.addListener(_maybePrefetchNext);
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _loadFirstPage() async {
    try {
      final items = await _service.fetchNews(page: _pageNum);
      setState(() {
        _articles.addAll(items);
        _initialLoading = false;
      });
    } catch (e) {
      setState(() => _initialLoading = false);
      _snack('Failed to load news: $e');
    }
  }

  void _maybePrefetchNext() {
    if (_loadingMore || _articles.isEmpty) return;
    final pos = _page.position;
    if (!pos.hasPixels || !pos.hasContentDimensions) return;

    final threshold = pos.maxScrollExtent - MediaQuery.of(context).size.height * 1.5;
    if (pos.pixels >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      _pageNum += 1;
      final items = await _service.fetchNews(page: _pageNum);
      if (items.isNotEmpty) {
        setState(() => _articles.addAll(items));
      }
    } catch (e) {
      _snack('Could not load more: $e');
      _pageNum -= 1;
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _initialLoading = true;
      _articles.clear();
      _pageNum = 1;
      _currentIndex = 0;
    });
    await _loadFirstPage();
    _page.jumpToPage(0);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dailyGoal = 10;
    final progressText = '${appState.todayCount} of $dailyGoal briefings today';

    return Scaffold(
      appBar: AppBar(
        title: const Text('ProNews'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                progressText,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _tab == 0
          ? (_initialLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    PageView.builder(
                      controller: _page,
                      scrollDirection: Axis.vertical,
                      itemCount: _articles.length,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemBuilder: (_, i) => NewsCard(
                        article: _articles[i],
                        appState: appState,
                        onViewed: () {}, // counted inside card once summary loads
                      ),
                    ),
                    if (_loadingMore)
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 16,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ))
          : (_tab == 1
              ? BookmarksScreen(appState: appState)
              : ProfileScreen(appState: appState)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.article_outlined), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.bookmark_border), label: 'Bookmarks'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
