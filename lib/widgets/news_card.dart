import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../providers/app_state.dart';
import '../services/summary_service.dart';
import 'shimmer_card.dart';

class NewsCard extends StatefulWidget {
  final Article article;
  final AppState appState;
  final VoidCallback onViewed;

  const NewsCard({
    super.key,
    required this.article,
    required this.appState,
    required this.onViewed,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  final _summaryService = SummaryService();
  String? _bullets;
  bool _loading = true;
  bool _error = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final s = await _summaryService.getBulletSummary(widget.article);
      if (!mounted) return;
      setState(() {
        _bullets = s;
        _loading = false;
      });
      if (!_counted) {
        _counted = true;
        widget.appState.incrementProgress();
        widget.onViewed();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final date = DateFormat('MMM d, yyyy').format(a.publishedAt);
    final bookmarked = widget.appState.isBookmarked(a);

    if (_loading) return const ShimmerCard();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source + date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${a.source} • $date',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  IconButton(
                    tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark',
                    onPressed: () => widget.appState.toggleBookmark(a),
                    icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Headline
              Text(
                a.title,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              if (_error) ...[
                const Text(
                  'Could not load key takeaways.',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _loadSummary,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const Spacer(),
              ] else ...[
                // 6 bullet points
                if ((_bullets ?? '').isNotEmpty)
                  ..._bullets!
                      .split('\n')
                      .where((l) => l.trim().isNotEmpty)
                      .map((l) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('•  '),
                                Expanded(
                                  child: Text(
                                    l.replaceFirst(RegExp(r'^•\s*'), ''),
                                    style: const TextStyle(fontSize: 16, height: 1.42),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList()
                else
                  const Text('No summary available.'),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Container(),
                    ),
                    TextButton.icon(
                      onPressed: () => _openUrl(a.url),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Read more'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
