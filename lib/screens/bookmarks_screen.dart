import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../providers/app_state.dart';

class BookmarksScreen extends StatefulWidget {
  final AppState appState;
  const BookmarksScreen({super.key, required this.appState});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.appState.applyFilters(widget.appState.bookmarks);
    final sources = widget.appState.bookmarks.map((a) => a.source).toSet().toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => widget.appState.searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'Search bookmarks',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: DropdownButtonFormField<String>(
              value: widget.appState.filterSource,
              hint: const Text('Filter by source'),
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('All')),
                ...sources.map((s) =>
                    DropdownMenuItem<String>(value: s, child: Text(s))),
              ],
              onChanged: (v) => setState(() => widget.appState.filterSource = v),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final a = filtered[i];
                return ListTile(
                  title: Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${a.source} • ${DateFormat('MMM d, yyyy').format(a.publishedAt)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () => _open(a.url),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
