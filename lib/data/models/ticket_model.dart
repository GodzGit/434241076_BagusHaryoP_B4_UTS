import 'comment_model.dart';
import '../../core/constants/app_constants.dart';

class TicketModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String userId;
  final String userName;
  final String? assignedTo;
  final List<CommentModel> comments;
  final List<String> attachments;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.userName,
    this.assignedTo,
    required this.comments,
    required this.attachments,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      userId: json['userId'],
      userName: json['userName'],
      assignedTo: json['assignedTo'],
      comments: (json['comments'] as List)
          .map((c) => CommentModel.fromJson(c))
          .toList(),
      attachments: List<String>.from(json['attachments']),
    );
  }

  String get statusText {
    switch (status) {
      case AppConstants.statusOpen:
        return 'Open';
      case AppConstants.statusInProgress:
        return 'In Progress';
      case AppConstants.statusResolved:
        return 'Resolved';
      case AppConstants.statusClosed:
        return 'Closed';
      default:
        return status;
    }
  }
}