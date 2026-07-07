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
  final String? assignedToName;
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
    this.assignedToName,
    required this.comments,
    required this.attachments,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'open',
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
      updatedAt: json['updated_at'] ?? json['updatedAt'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      userName: json['user_profile'] != null
          ? (json['user_profile']['name'] ?? 'Unknown')
          : (json['profiles'] != null
              ? (json['profiles']['name'] ?? 'Unknown')
              : (json['userName'] ?? 'Unknown')),
      assignedTo: json['assigned_to'] ?? json['assignedTo'],
      assignedToName: json['assigned_profile'] != null
          ? json['assigned_profile']['name']
          : (json['assignedToName']),
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((c) => CommentModel.fromJson(c))
              .toList()
          : [],
      attachments: json['attachments'] != null
          ? List<String>.from((json['attachments'] as List).map((a) {
              if (a is Map) {
                return a['file_url'] as String;
              }
              return a.toString();
            }))
          : [],
    );
  }

  String get statusText {
    switch (status) {
      case AppConstants.statusOpen:
        return 'Open';
      case AppConstants.statusAssign:
        return 'Assign';
      case AppConstants.statusInProgress:
        return 'In Progress';
      case AppConstants.statusClosed:
        return 'Closed';
      default:
        return status;
    }
  }
}