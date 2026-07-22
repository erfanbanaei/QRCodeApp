enum HistorySource { generated, scanned }

class HistoryItem {
  final String id;
  final String data;
  final String title;
  final HistorySource source;
  final DateTime createdAt;

  const HistoryItem({
    required this.id,
    required this.data,
    required this.title,
    required this.source,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data,
        'title': title,
        'source': source.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      data: json['data'] as String,
      title: json['title'] as String,
      source: HistorySource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => HistorySource.generated,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
