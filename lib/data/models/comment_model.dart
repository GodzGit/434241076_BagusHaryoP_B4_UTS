class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final String createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'].toString(),
      userId: json['user_id'] ?? json['userId'] ?? '',
      userName: json['profiles'] != null
          ? (json['profiles']['name'] ?? 'Unknown')
          : (json['userName'] ?? 'Unknown'),
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
    );
  }
}