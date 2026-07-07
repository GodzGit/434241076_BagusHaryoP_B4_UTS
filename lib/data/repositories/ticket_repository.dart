import 'package:image_picker/image_picker.dart';
import '../../services/supabase_service.dart';

class TicketRepository {
  final SupabaseService _supabaseService = SupabaseService();

  Future<List<Map<String, dynamic>>> getTickets(String userId, String role) async {
    return await _supabaseService.getTickets(userId, role);
  }

  Future<Map<String, dynamic>> getTicketDetail(String ticketId) async {
    final id = int.tryParse(ticketId);
    if (id == null) {
      throw Exception('ID tiket tidak valid');
    }
    return await _supabaseService.getTicketDetail(id);
  }

  Future<Map<String, dynamic>> createTicket({
    required String title,
    required String description,
    required String userId,
    List<XFile> attachments = const [],
  }) async {
    List<String> attachmentUrls = [];
    for (var file in attachments) {
      final fileName = file.name;
      try {
        final bytes = await file.readAsBytes();
        final url = await _supabaseService.uploadFile(bytes, fileName);
        attachmentUrls.add(url);
      } catch (e) {
        print('Error uploading file ${file.name}: $e');
        throw Exception('Gagal mengunggah berkas $fileName. Pastikan RLS Storage & Bucket "ticket-attachments" sudah dikonfigurasi di Supabase. Detail: $e');
      }
    }
    
    return await _supabaseService.createTicket(
      title: title,
      description: description,
      userId: userId,
      attachmentUrls: attachmentUrls,
    );
  }

  Future<Map<String, dynamic>> updateTicketStatus(String ticketId, String status) async {
    final id = int.tryParse(ticketId);
    if (id == null) {
      throw Exception('ID tiket tidak valid');
    }
    return await _supabaseService.updateTicketStatus(id, status);
  }

  Future<Map<String, dynamic>> acceptTicket(String ticketId) async {
    final id = int.tryParse(ticketId);
    if (id == null) {
      throw Exception('ID tiket tidak valid');
    }
    return await _supabaseService.acceptTicket(id);
  }

  Future<Map<String, dynamic>> assignTicket(String ticketId, String helpdeskId) async {
    final id = int.tryParse(ticketId);
    if (id == null) {
      throw Exception('ID tiket tidak valid');
    }
    return await _supabaseService.assignTicket(id, helpdeskId);
  }

  Future<Map<String, dynamic>> finishTicket(String ticketId) async {
    final id = int.tryParse(ticketId);
    if (id == null) {
      throw Exception('ID tiket tidak valid');
    }
    return await _supabaseService.finishTicket(id);
  }

  Future<List<Map<String, dynamic>>> getHelpdeskUsers() async {
    return await _supabaseService.getHelpdeskUsers();
  }

  Future<Map<String, dynamic>> addComment({
    required String ticketId,
    required String userId,
    required String content,
  }) async {
    final id = int.tryParse(ticketId);
    if (id == null) {
      throw Exception('ID tiket tidak valid');
    }
    return await _supabaseService.addComment(
      ticketId: id,
      userId: userId,
      content: content,
    );
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    return await _supabaseService.getDashboardStats();
  }
}
