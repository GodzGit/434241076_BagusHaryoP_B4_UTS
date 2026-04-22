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
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      content: json['content'],
      createdAt: json['createdAt'],
    );
  }
}