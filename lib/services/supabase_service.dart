import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient supabase;

  Future<void> init() async {
    await Supabase.initialize(
      url: 'https://xjeseqhmfwycmutvlwsf.supabase.co', // GANTI DENGAN URL MU
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhqZXNlcWhtZnd5Y211dHZsd3NmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMyNjA1MDcsImV4cCI6MjA5ODgzNjUwN30.p9jH6urmir852Xi9yckxALfpolGhHCGeIs6TbsA6fMo', // GANTI DENGAN ANON KEY MU
    );
    supabase = Supabase.instance.client;
  }

  // ============ AUTH METHODS ============
  Future<AuthResponse> signUp(String email, String password, String name) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Session? get currentSession => supabase.auth.currentSession;
  User? get currentUser => supabase.auth.currentUser;

  // ============ PROFILE METHODS ============
  Future<Map<String, dynamic>> getProfile(String userId) async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateProfile(String userId, {String? name}) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    
    final response = await supabase
        .from('profiles')
        .update(data)
        .eq('id', userId)
        .select()
        .single();
    return response;
  }

  // ============ TICKET METHODS ============
  Future<List<Map<String, dynamic>>> getTickets(String userId, String role) async {
    try {
      if (role == 'user') {
        final response = await supabase
            .from('tickets')
            .select('*, user_profile:profiles!user_id(name), assigned_profile:profiles!assigned_to(name)')
            .eq('user_id', userId)
            .order('created_at', ascending: false);
        return response;
      } else {
        final response = await supabase
            .from('tickets')
            .select('*, user_profile:profiles!user_id(name), assigned_profile:profiles!assigned_to(name)')
            .order('created_at', ascending: false);
        return response;
      }
    } catch (e) {
      print('Error getTickets: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getTicketDetail(int ticketId) async {
    final response = await supabase
        .from('tickets')
        .select('*, user_profile:profiles!user_id(name), assigned_profile:profiles!assigned_to(name)')
        .eq('id', ticketId)
        .single();
    
    // Get comments
    final comments = await supabase
        .from('comments')
        .select('*, profiles(name)')
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);
    
    // Get attachments
    final attachments = await supabase
        .from('attachments')
        .select()
        .eq('ticket_id', ticketId);
    
    return {
      ...response,
      'comments': comments,
      'attachments': attachments,
    };
  }

  Future<Map<String, dynamic>> createTicket({
    required String title,
    required String description,
    required String userId,
    required List<String> attachmentUrls,
  }) async {
    final response = await supabase
        .from('tickets')
        .insert({
          'title': title,
          'description': description,
          'user_id': userId,
          'status': 'open',
        })
        .select()
        .single();
    
    // Add attachments if any
    for (String url in attachmentUrls) {
      await supabase
          .from('attachments')
          .insert({
            'ticket_id': response['id'],
            'file_url': url,
            'file_name': url.split('/').last,
          });
    }
    
    return response;
  }

  Future<Map<String, dynamic>> updateTicketStatus(int ticketId, String status) async {
    final response = await supabase
        .from('tickets')
        .update({'status': status})
        .eq('id', ticketId)
        .select('*, user_profile:profiles!user_id(name), assigned_profile:profiles!assigned_to(name)')
        .single();
    return response;
  }

  Future<Map<String, dynamic>> acceptTicket(int ticketId) async {
    final response = await supabase
        .from('tickets')
        .update({'status': 'assign'})
        .eq('id', ticketId)
        .select('*, user_profile:profiles!user_id(name), assigned_profile:profiles!assigned_to(name)')
        .single();
    return response;
  }

  Future<Map<String, dynamic>> assignTicket(int ticketId, String helpdeskId) async {
    final response = await supabase
        .from('tickets')
        .update({
          'assigned_to': helpdeskId,
          'status': 'in_progress',
        })
        .eq('id', ticketId)
        .select('*, user_profile:profiles!user_id(name), assigned_profile:profiles!assigned_to(name)')
        .single();
    return response;
  }

  Future<Map<String, dynamic>> finishTicket(int ticketId) async {
    final response = await supabase
        .from('tickets')
        .update({'status': 'closed'})
        .eq('id', ticketId)
        .select('*, user_profile:profiles!user_id(name), assigned_profile:profiles!assigned_to(name)')
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> getHelpdeskUsers() async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('role', 'helpdesk')
        .order('name', ascending: true);
    return response;
  }

  Future<Map<String, dynamic>> addComment({
    required int ticketId,
    required String userId,
    required String content,
  }) async {
    final response = await supabase
        .from('comments')
        .insert({
          'ticket_id': ticketId,
          'user_id': userId,
          'content': content,
        })
        .select()
        .single();
    return response;
  }

  // ============ STORAGE METHODS ============
  Future<String> uploadFile(Uint8List fileBytes, String fileName) async {
    final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final storagePath = uniqueFileName;
    
    await supabase.storage.from('ticket-attachments').uploadBinary(
      storagePath,
      fileBytes,
    );
    
    final url = supabase.storage.from('ticket-attachments').getPublicUrl(storagePath);
    return url;
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final tickets = await supabase.from('tickets').select();
    
    int total = tickets.length;
    int open = tickets.where((t) => t['status'] == 'open').length;
    int assign = tickets.where((t) => t['status'] == 'assign').length;
    int inProgress = tickets.where((t) => t['status'] == 'in_progress').length;
    int closed = tickets.where((t) => t['status'] == 'closed').length;
    
    return {
      'total': total,
      'open': open,
      'assign': assign,
      'inProgress': inProgress,
      'closed': closed,
    };
  }
}