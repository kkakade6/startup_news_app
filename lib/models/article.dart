class Article {
  final String id; // stable id for caching/bookmarks
  final String title;
  final String description;
  final String url;
  final String source;
  final DateTime publishedAt;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    required this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final url = (json['url'] ?? '').toString();
    return Article(
      id: url, // use url as a stable id for MVP
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      url: url,
      source: (json['source']?['name'] ?? 'Unknown').toString(),
      publishedAt: DateTime.tryParse((json['publishedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'url': url,
        'source': source,
        'publishedAt': publishedAt.toIso8601String(),
      };

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      url: (map['url'] ?? '').toString(),
      source: (map['source'] ?? '').toString(),
      publishedAt:
          DateTime.tryParse((map['publishedAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
