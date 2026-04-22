import 'package:flutter/material.dart';
import '../core/utils/mock_api.dart';
import '../core/constants/app_constants.dart';
import '../data/models/ticket_model.dart';
import '../data/models/user_model.dart';

class TicketProvider extends ChangeNotifier {
  List<TicketModel> _tickets = [];
  TicketModel? _currentTicket;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _dashboardStats;

  List<TicketModel> get tickets => _tickets;
  TicketModel? get currentTicket => _currentTicket;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get dashboardStats => _dashboardStats;

  // Load all tickets based on user role
  Future<void> loadTickets(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ticketsData = await MockApi.getTickets(user.id, user.role);
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
      final ticketData = await MockApi.getTicketDetail(ticketId);
      _currentTicket = TicketModel.fromJson(ticketData);
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
    List<String> attachments = const [],
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newTicket = await MockApi.createTicket(
        title: title,
        description: description,
        userId: userId,
        userName: userName,
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

  // Update ticket status (Admin/Helpdesk only)
  Future<bool> updateTicketStatus(String ticketId, String newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTicket = await MockApi.updateTicketStatus(ticketId, newStatus);
      
      // Update in list
      final index = _tickets.indexWhere((t) => t.id == ticketId);
      if (index != -1) {
        _tickets[index] = TicketModel.fromJson(updatedTicket);
      }
      
      // Update current ticket if open
      if (_currentTicket != null && _currentTicket!.id == ticketId) {
        _currentTicket = TicketModel.fromJson(updatedTicket);
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

  // Assign ticket to helpdesk (Admin only)
  Future<bool> assignTicket(String ticketId, String assignedTo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTicket = await MockApi.assignTicket(ticketId, assignedTo);
      
      // Update in list
      final index = _tickets.indexWhere((t) => t.id == ticketId);
      if (index != -1) {
        _tickets[index] = TicketModel.fromJson(updatedTicket);
      }
      
      // Update current ticket if open
      if (_currentTicket != null && _currentTicket!.id == ticketId) {
        _currentTicket = TicketModel.fromJson(updatedTicket);
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
      final updatedTicket = await MockApi.addComment(
        ticketId: ticketId,
        userId: userId,
        userName: userName,
        content: content,
      );
      
      // Update current ticket
      if (_currentTicket != null && _currentTicket!.id == ticketId) {
        _currentTicket = TicketModel.fromJson(updatedTicket);
      }
      
      // Update in list
      final index = _tickets.indexWhere((t) => t.id == ticketId);
      if (index != -1) {
        _tickets[index] = TicketModel.fromJson(updatedTicket);
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
      _dashboardStats = await MockApi.getDashboardStats(role);
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

  // Get in progress tickets
  int get inProgressTicketsCount {
    return _tickets.where((t) => t.status == AppConstants.statusInProgress).length;
  }

  // Get resolved tickets
  int get resolvedTicketsCount {
    return _tickets.where((t) => t.status == AppConstants.statusResolved).length;
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