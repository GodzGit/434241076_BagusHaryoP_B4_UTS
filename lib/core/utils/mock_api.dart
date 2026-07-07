import 'dart:convert';
import 'dart:math';
import '../constants/app_constants.dart';

class MockApi {
  // Simulasi delay network
  static Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ============ AUTH ============
  static Future<Map<String, dynamic>> login(String email, String password) async {
    await _delay();

    // Validasi sederhana
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email dan password tidak boleh kosong');
    }

    // Mock user data
    final mockUsers = {
      'user@mail.com': {
        'id': '1',
        'name': 'San Usir',
        'email': 'user@mail.com',
        'role': AppConstants.roleUser,
        'password': '123456',
      },
      'helpdesk@mail.com': {
        'id': '2',
        'name': 'Petugas Helpdesk',
        'email': 'helpdesk@mail.com',
        'role': AppConstants.roleHelpdesk,
        'password': '123456',
      },
      'admin@mail.com': {
        'id': '3',
        'name': 'Administrator',
        'email': 'admin@mail.com',
        'role': AppConstants.roleAdmin,
        'password': '123456',
      },
    };

    final user = mockUsers[email];
    if (user != null && user['password'] == password) {
      return {
        'success': true,
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': user['id'],
          'name': user['name'],
          'email': user['email'],
          'role': user['role'],
        },
      };
    } else {
      throw Exception('Email atau password salah');
    }
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    await _delay();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('Semua field harus diisi');
    }

    if (password.length < 6) {
      throw Exception('Password minimal 6 karakter');
    }

    return {
      'success': true,
      'message': 'Registrasi berhasil, silakan login',
    };
  }

  // ============ TICKETS ============
  static final List<Map<String, dynamic>> _tickets = [
    {
      'id': 'TCK001',
      'title': 'WiFi tidak bisa connect',
      'description': 'Sudah coba restart tetap tidak bisa connect ke WiFi kantor',
      'status': AppConstants.statusOpen,
      'createdAt': '2026-04-20 09:00:00',
      'updatedAt': '2026-04-20 09:00:00',
      'userId': '1',
      'userName': 'San Usir',
      'assignedTo': null,
      'comments': [],
      'attachments': [],
    },
    {
      'id': 'TCK002',
      'title': 'Printer tidak merespon',
      'description': 'Printer di ruang meeting tidak bisa print',
      'status': AppConstants.statusInProgress,
      'createdAt': '2026-04-19 14:30:00',
      'updatedAt': '2026-04-20 08:00:00',
      'userId': '1',
      'userName': 'San Usir',
      'assignedTo': 'Petugas Helpdesk',
      'comments': [
        {
          'id': 'c1',
          'userId': '2',
          'userName': 'Petugas Helpdesk',
          'content': 'Sedang kami cek, mohon tunggu',
          'createdAt': '2026-04-20 08:00:00',
        },
      ],
      'attachments': [],
    },
    {
      'id': 'TCK003',
      'title': 'Email error',
      'description': 'Tidak bisa mengirim email dengan attachment',
      'status': AppConstants.statusClosed,
      'createdAt': '2026-04-18 10:00:00',
      'updatedAt': '2026-04-19 16:00:00',
      'userId': '2',
      'userName': 'Petugas Helpdesk',
      'assignedTo': 'Administrator',
      'comments': [],
      'attachments': [],
    },
  ];

  static Future<List<Map<String, dynamic>>> getTickets(String userId, String role) async {
    await _delay();

    if (role == AppConstants.roleAdmin || role == AppConstants.roleHelpdesk) {
      return _tickets;
    } else {
      return _tickets.where((t) => t['userId'] == userId).toList();
    }
  }

  static Future<Map<String, dynamic>> getTicketDetail(String ticketId) async {
    await _delay();

    final ticket = _tickets.firstWhere((t) => t['id'] == ticketId);
    return ticket;
  }

  static Future<Map<String, dynamic>> createTicket({
    required String title,
    required String description,
    required String userId,
    required String userName,
    List<String> attachments = const [],
  }) async {
    await _delay();

    final newTicket = {
      'id': 'TCK${_tickets.length + 1}'.padLeft(6, '0'),
      'title': title,
      'description': description,
      'status': AppConstants.statusOpen,
      'createdAt': DateTime.now().toString().substring(0, 19).replaceAll(' ', ' '),
      'updatedAt': DateTime.now().toString().substring(0, 19).replaceAll(' ', ' '),
      'userId': userId,
      'userName': userName,
      'assignedTo': null,
      'comments': [],
      'attachments': attachments,
    };

    _tickets.insert(0, newTicket);
    return newTicket;
  }

  static Future<Map<String, dynamic>> updateTicketStatus(
    String ticketId,
    String newStatus,
  ) async {
    await _delay();

    final index = _tickets.indexWhere((t) => t['id'] == ticketId);
    if (index != -1) {
      _tickets[index]['status'] = newStatus;
      _tickets[index]['updatedAt'] =
          DateTime.now().toString().substring(0, 19).replaceAll(' ', ' ');
      return _tickets[index];
    }
    throw Exception('Tiket tidak ditemukan');
  }

  static Future<Map<String, dynamic>> assignTicket(
    String ticketId,
    String assignedTo,
  ) async {
    await _delay();

    final index = _tickets.indexWhere((t) => t['id'] == ticketId);
    if (index != -1) {
      _tickets[index]['assignedTo'] = assignedTo;
      _tickets[index]['updatedAt'] =
          DateTime.now().toString().substring(0, 19).replaceAll(' ', ' ');
      return _tickets[index];
    }
    throw Exception('Tiket tidak ditemukan');
  }

  static Future<Map<String, dynamic>> addComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String content,
  }) async {
    await _delay();

    final index = _tickets.indexWhere((t) => t['id'] == ticketId);
    if (index != -1) {
      final newComment = {
        'id': 'c${_tickets[index]['comments'].length + 1}',
        'userId': userId,
        'userName': userName,
        'content': content,
        'createdAt':
            DateTime.now().toString().substring(0, 19).replaceAll(' ', ' '),
      };
      _tickets[index]['comments'].add(newComment);
      _tickets[index]['updatedAt'] =
          DateTime.now().toString().substring(0, 19).replaceAll(' ', ' ');
      return _tickets[index];
    }
    throw Exception('Tiket tidak ditemukan');
  }

  static Future<Map<String, dynamic>> getDashboardStats(String role) async {
    await _delay();

    final total = _tickets.length;
    final open = _tickets.where((t) => t['status'] == AppConstants.statusOpen).length;
    final inProgress =
        _tickets.where((t) => t['status'] == AppConstants.statusInProgress).length;
    final closed =
        _tickets.where((t) => t['status'] == AppConstants.statusClosed).length;

    return {
      'total': total,
      'open': open,
      'inProgress': inProgress,
      'closed': closed,
    };
  }
}