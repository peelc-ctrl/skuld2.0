import 'user.dart';

class FeedItem {
  final String id;
  final User user;
  final String contentType;
  final String content;
  final DateTime createdAt;
  final int skolCount;
  final bool hasSkolled;

  FeedItem({
    required this.id,
    required this.user,
    required this.contentType,
    required this.content,
    required this.createdAt,
    required this.skolCount,
    required this.hasSkolled,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'].toString(),
      user: User.fromJson(json['user']),
      contentType: json['content_type'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      skolCount: json['skol_count'],
      hasSkolled: json['has_skolled'],
    );
  }
}
