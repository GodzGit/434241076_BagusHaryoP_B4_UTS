import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_constants.dart';
import '../data/models/comment_model.dart';
import '../data/models/ticket_model.dart';
import '../data/models/user_model.dart';
import '../data/repositories/ticket_repository.dart';

class TicketProvider extends ChangeNotifier {
  final TicketRepository _ticketRepository = TicketRepository();
  
  List<TicketModel> _tickets = [];
  TicketModel? _currentTicket;
  List<UserModel> _helpdeskUsers = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _dashboardStats;

  List<TicketModel> get tickets => _tickets;
  TicketModel? get currentTicket => _currentTicket;
  List<UserModel> get helpdeskUsers => _helpdeskUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get dashboardStats => _dashboardStats;

  // Load all tickets based on user role
  Future<void> loadTickets(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ticketsData = await _ticketRepository.getTickets(user.id, user.role);
      _tickets = ticketsData.map((t) => TicketModel.fromJson(t)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load ticket detail
  Future<void> loadTicketDetail(String ticketId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ticketData = await _ticketRepository.getTicketDetail(ticketId);
      _currentTicket = TicketModel.fromJson(ticketData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load helpdesk users list
  Future<void> loadHelpdeskUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final helpdeskData = await _ticketRepository.getHelpdeskUsers();
      _helpdeskUsers = helpdeskData.map((u) => UserModel.fromJson(u)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new ticket
  Future<bool> createTicket({
    required String title,
    required String description,
    required String userId,
    required String userName,
    List<XFile> attachments = const [],
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newTicket = await _ticketRepository.createTicket(
        title: title,
        description: description,
        userId: userId,
        attachments: attachments,
      );
      
      // Add to local list
      final ticketModel = TicketModel.fromJson(newTicket);
      _tickets.insert(0, ticketModel);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Accept ticket (Admin only)
  Future<bool> acceptTicket(String ticketId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTicket = await _ticketRepository.acceptTicket(ticketId);
      final ticketModel = TicketModel.fromJson(updatedTicket);
      
      // Preserve comments & attachments from previous current ticket state
      List<CommentModel> existingComments = [];
      List<String> existingAttachments = [];
      if (_currentTicket != null && _currentTicket!.id == ticketId) {
        existingComments = _currentTicket!.comments;
        existingAttachments = _currentTicket!.attachments;
      }
      
      // Update in list
      final index = _tickets.indexWhere((t) => t.id == ticketId);
      if (index != -1) {
        final oldTicket = _tickets[index];
        _tickets[index] = TicketModel(
          id: ticketModel.id,
          title: ticketModel.title,
          description: ticketModel.description,
          status: ticketModel.status,
          createdAt: ticketModel.createdAt,
          updatedAt: ticketModel.updatedAt,
          userId: ticketModel.userId,
          userName: ticketModel.userName,
          assignedTo: ticketModel.assignedTo,
          assignedToName: ticketModel.assignedToName,
          comments: oldTicket.comments,
          attachments: ticketModel.attachments.isNotEmpty ? ticketModel.attachments : oldTicket.attachments,
        );
        if (existingComments.isEmpty) {
          existingComments = oldTicket.comments;
        }
        if (existingAttachments.isEmpty) {
          existingAttachments = oldTicket.attachments;
        }
      }
      
      // Update current ticket
      if (_currentTicket != null && _currentTicket!.id == ticketId) {
        _currentTicket = TicketModel(
          id: ticketModel.id,
          title: ticketModel.title,
          description: ticketModel.description,
          status: ticketModel.status,
          createdAt: ticketModel.createdAt,
          updatedAt: ticketModel.updatedAt,
          userId: ticketModel.userId,
          userName: ticketModel.userName,
          assignedTo: ticketModel.assignedTo,
          assignedToName: ticketModel.assignedToName,
          comments: existingComments,
          attachments: ticketModel.attachments.isNotEmpty ? ticketModel.attachments : existingAttachments,
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Assign ticket to helpdesk user (Admin only)
  Future<bool> assignTicket(String ticketId, String helpdeskId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTicket = await _ticketRepository.assignTicket(ticketId, helpdeskId);
      final ticketModel = TicketModel.fromJson(updatedTicket);
      
      // Preserve comments & attachments from previous current ticket state
      List<CommentModel> existingComments = [];
      List<String> existingAttachments = [];
      if (_currentTicket != null && _currentTicket!.id == ticketId) {
        existingComments = _currentTicket!.comments;
        existingAttachments = _currentTicket!.attachments;
      }
      
      // Update in list
      final index = _tickets.indexWhere((t) => t.id == ticketId);
      if (index != -1) {
        final oldTicket = _tickets[index];
        _tickets[index] = TicketModel(
          id: ticketModel.id,
          title: ticketModel.title,
          description: ticketModel.description,
          status: ticketModel.status,
          createdAt: ticketModel.createdAt,
          updatedAt: ticketModel.updatedAt,
          userId: ticketModel.userId,
          userName: ticketModel.userName,
          assignedTo: ticketModel.assignedTo,
          assignedToName: ticketModel.assignedToName,
          comments: oldTicket.comments,
          attachments: ticketModel.attachments.isNotEmpty ? ticketModel.attachments : oldTicket.attachments,
        );
        if (existingComments.isEmpty) {
          existingComments = oldTicket.comments;
        }
        if (existingAttachments.isEmpty) {
          existingAttachments = oldTicket.attachments;
        }
      }
      
      // Update current ticket
      if (_currentTicket != null && _currentTicket!.id == ticketId) {
        _currentTicket = TicketModel(
          id: ticketModel.id,
          title: ticketModel.title,
          description: ticketModel.description,
          status: ticketModel.status,
          createdAt: ticketModel.createdAt,
          updatedAt: ticketModel.updatedAt,
          userId: ticketModel.userId,
          userName: ticketModel.userName,
          assignedTo: ticketModel.assignedTo,
          assignedToName: ticketModel.assignedToName,
          comments: existingComments,
          attachments: ticketModel.attachments.isNotEmpty ? ticketModel.attachments : existingAttachments,
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Finish ticket (Helpdesk/Admin)
  Future<bool> finishTicket(String ticketId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTicket = await _ticketRepository.finishTicket(ticketId);
      final ticketModel = TicketModel.fromJson(updatedTicket);
      
      // Preserve comments & attachments from previous current ticket state
      List<CommentModel> existingComments = [];
      List<String> existingAttachments = [];
      if (_currentTicket != null && _currentTicket!.id == ticketId) {
        existingComments = _currentTicket!.comments;
        existingAttachments = _currentTicket!.attachments;
      }
      
      // Update in list
      final index = _tickets.indexWhere((t) => t.id == ticketId);
      if (index != -1) {
        final oldTicket = _tickets[index];
        _tickets[index] = TicketModel(
          id: ticketModel.id,
          title: ticketModel.title,
          description: ticketModel.description,
          status: ticketModel.status,
          createdAt: ticketModel.createdAt,
          updatedAt: ticketModel.updatedAt,
          userId: ticketModel.userId,
          userName: ticketModel.userName,
          assignedTo: ticketModel.assignedTo,
          assignedToName: ticketModel.assignedToName,
          comments: oldTicket.comments,
          attachments: ticketModel.attachments.isNotEmpty ? ticketModel.attachments : oldTicket.attachments,
        );
        if (existingComments.isEmpty) {
          existingComments = oldTicket.comments;
        }
        if (existingAttachments.isEmpty) {
          existingAttachments = oldTicket.attachments;
        }
      }
      
      // Update current ticket
      if (_currentTicket != null && _currentTicket!.id == ticketId) {
        _currentTicket = TicketModel(
          id: ticketModel.id,
          title: ticketModel.title,
          description: ticketModel.description,
          status: ticketModel.status,
          createdAt: ticketModel.createdAt,
          updatedAt: ticketModel.updatedAt,
          userId: ticketModel.userId,
          userName: ticketModel.userName,
          assignedTo: ticketModel.assignedTo,
          assignedToName: ticketModel.assignedToName,
          comments: existingComments,
          attachments: ticketModel.attachments.isNotEmpty ? ticketModel.attachments : existingAttachments,
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add comment to ticket
  Future<bool> addComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String content,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final commentData = await _ticketRepository.addComment(
        ticketId: ticketId,
        userId: userId,
        content: content,
      );
      
      // Construct CommentModel from returned data and local user details
      final commentModel = CommentModel(
        id: commentData['id'].toString(),
        userId: userId,
        userName: userName,
        content: content,
        createdAt: commentData['created_at'] ?? DateTime.now().toIso8601String(),
      );

      // Update current ticket
      if (_currentTicket != null && _currentTicket!.id == ticketId) {
        final updatedComments = List<CommentModel>.from(_currentTicket!.comments)..add(commentModel);
        _currentTicket = TicketModel(
          id: _currentTicket!.id,
          title: _currentTicket!.title,
          description: _currentTicket!.description,
          status: _currentTicket!.status,
          createdAt: _currentTicket!.createdAt,
          updatedAt: _currentTicket!.updatedAt,
          userId: _currentTicket!.userId,
          userName: _currentTicket!.userName,
          assignedTo: _currentTicket!.assignedTo,
          assignedToName: _currentTicket!.assignedToName,
          comments: updatedComments,
          attachments: _currentTicket!.attachments,
        );
      }
      
      // Update in list
      final index = _tickets.indexWhere((t) => t.id == ticketId);
      if (index != -1) {
        final ticket = _tickets[index];
        final updatedComments = List<CommentModel>.from(ticket.comments)..add(commentModel);
        _tickets[index] = TicketModel(
          id: ticket.id,
          title: ticket.title,
          description: ticket.description,
          status: ticket.status,
          createdAt: ticket.createdAt,
          updatedAt: ticket.updatedAt,
          userId: ticket.userId,
          userName: ticket.userName,
          assignedTo: ticket.assignedTo,
          assignedToName: ticket.assignedToName,
          comments: updatedComments,
          attachments: ticket.attachments,
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load dashboard statistics
  Future<void> loadDashboardStats(String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      _dashboardStats = await _ticketRepository.getDashboardStats();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get tickets by status
  List<TicketModel> getTicketsByStatus(String status) {
    return _tickets.where((t) => t.status == status).toList();
  }

  // Get open tickets (for dashboard)
  int get openTicketsCount {
    return _tickets.where((t) => t.status == AppConstants.statusOpen).length;
  }

  // Get assign tickets
  int get assignTicketsCount {
    return _tickets.where((t) => t.status == AppConstants.statusAssign).length;
  }

  // Get in progress tickets
  int get inProgressTicketsCount {
    return _tickets.where((t) => t.status == AppConstants.statusInProgress).length;
  }

  // Get closed tickets
  int get closedTicketsCount {
    return _tickets.where((t) => t.status == AppConstants.statusClosed).length;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}