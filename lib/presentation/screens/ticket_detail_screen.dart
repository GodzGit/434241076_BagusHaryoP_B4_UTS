import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../data/models/user_model.dart';
import '../../data/models/ticket_model.dart';
import '../widgets/comment_item.dart';

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({super.key});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _commentController = TextEditingController();
  String? _selectedAssignee;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final ticketId = ModalRoute.of(context)?.settings.arguments as String;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadTicketDetail(ticketId);
        }
      });
      _isInitialized = true;
    }
  }

  Future<void> _loadTicketDetail(String ticketId) async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    await ticketProvider.loadTicketDetail(ticketId);
    
    if (authProvider.currentUser?.role == AppConstants.roleAdmin) {
      await ticketProvider.loadHelpdeskUsers();
    }
    
    if (ticketProvider.currentTicket != null) {
      setState(() {
        _selectedAssignee = ticketProvider.currentTicket!.assignedTo;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final ticket = ticketProvider.currentTicket;

    if (ticket != null) {
      final success = await ticketProvider.addComment(
        ticketId: ticket.id,
        userId: authProvider.currentUser!.id,
        userName: authProvider.currentUser!.name,
        content: _commentController.text.trim(),
      );

      if (success && mounted) {
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Komentar berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ticketProvider.errorMessage ?? 'Gagal menambah komentar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _acceptTicket() async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final ticket = ticketProvider.currentTicket;
    if (ticket != null) {
      final success = await ticketProvider.acceptTicket(ticket.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiket berhasil diterima untuk diproses'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ticketProvider.errorMessage ?? 'Gagal menerima tiket'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _assignTicket() async {
    if (_selectedAssignee == null || _selectedAssignee!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih petugas helpdesk terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final ticket = ticketProvider.currentTicket;
    if (ticket != null) {
      final success = await ticketProvider.assignTicket(ticket.id, _selectedAssignee!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiket berhasil ditugaskan dan berstatus In Progress'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ticketProvider.errorMessage ?? 'Gagal assign tiket'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _finishTicket() async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final ticket = ticketProvider.currentTicket;
    if (ticket != null) {
      final success = await ticketProvider.finishTicket(ticket.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiket berhasil diselesaikan dan ditutup'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ticketProvider.errorMessage ?? 'Gagal menyelesaikan tiket'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusOpen:
        return Colors.orange;
      case AppConstants.statusAssign:
        return Colors.indigo;
      case AppConstants.statusInProgress:
        return Colors.blue;
      case AppConstants.statusClosed:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);
    final ticket = ticketProvider.currentTicket;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket'),
        bottom: ticketProvider.isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: ticketProvider.isLoading && ticket == null
          ? const LoadingIndicator(message: 'Memuat detail tiket...')
          : ticket == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tiket tidak ditemukan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tiket #${ticket.id}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(ticket.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      ticket.statusText,
                                      style: TextStyle(
                                        color: _getStatusColor(ticket.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                ticket.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                ticket.description,
                                style: const TextStyle(fontSize: 16),
                               ),
                              const SizedBox(height: 12),
                              if (ticket.attachments.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Text(
                                  'Lampiran:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 120,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: ticket.attachments.length,
                                    itemBuilder: (context, index) {
                                      final url = ticket.attachments[index];
                                      return GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: Stack(
                                                alignment: Alignment.topRight,
                                                children: [
                                                  InteractiveViewer(
                                                    child: Image.network(
                                                      url,
                                                      loadingBuilder: (context, child, loadingProgress) {
                                                        if (loadingProgress == null) return child;
                                                        return const Center(child: CircularProgressIndicator());
                                                      },
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return const Center(
                                                          child: Padding(
                                                            padding: EdgeInsets.all(32.0),
                                                            child: Text('Gagal memuat gambar'),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.close, color: Colors.white),
                                                    style: IconButton.styleFrom(
                                                      backgroundColor: Colors.black.withOpacity(0.5),
                                                    ),
                                                    onPressed: () => Navigator.pop(context),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 12),
                                          width: 120,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              url,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return const Center(child: CircularProgressIndicator());
                                              },
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Center(
                                                  child: Icon(Icons.broken_image, color: Colors.grey),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Divider(color: Colors.grey[300]),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Dibuat oleh: ${ticket.userName}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Dibuat: ${ticket.createdAt.length >= 10 ? ticket.createdAt.substring(0, 10) : ticket.createdAt}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              if (ticket.assignedToName != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.person_add, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Assign ke: ${ticket.assignedToName}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action panel with RBAC rules
                      _buildActionPanel(context, ticket, authProvider.currentUser, ticketProvider),
                      const SizedBox(height: 16),

                      // Comments Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                           child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Komentar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (ticket.comments.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Text(
                                      'Belum ada komentar',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: ticket.comments.length,
                                  itemBuilder: (context, index) {
                                    final comment = ticket.comments[index];
                                    return CommentItem(comment: comment);
                                  },
                                ),
                              const Divider(),
                              const SizedBox(height: 8),
                              if (ticket.status == AppConstants.statusClosed)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.lock_outline, color: Colors.grey[600], size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Tiket telah ditutup. Kolom komentar dikunci.',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                TextField(
                                  controller: _commentController,
                                  decoration: InputDecoration(
                                    hintText: 'Tulis komentar...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.send),
                                      onPressed: _addComment,
                                    ),
                                  ),
                                  maxLines: 3,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildActionPanel(
    BuildContext context,
    TicketModel ticket,
    UserModel? currentUser,
    TicketProvider ticketProvider,
  ) {
    if (currentUser == null) return const SizedBox.shrink();

    final isAdmin = currentUser.role == AppConstants.roleAdmin;
    final isAssignedHelpdesk = currentUser.role == AppConstants.roleHelpdesk && ticket.assignedTo == currentUser.id;

    // 1. Status OPEN -> Admin can ACCEPT the ticket
    if (ticket.status == AppConstants.statusOpen) {
      if (isAdmin) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tindakan Admin (Status: Open)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Terima Tiket',
                  onPressed: _acceptTicket,
                ),
              ],
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    // 2. Status ASSIGN -> Admin can ASSIGN to a helpdesk agent via Dropdown
    if (ticket.status == AppConstants.statusAssign) {
      if (isAdmin) {
        final helpdesks = ticketProvider.helpdeskUsers;
        final hasError = ticketProvider.errorMessage != null;
        
        // Ensure that if the current selected assignee is not in the list of loaded helpdesks, we clear it or handle it
        final hasValidSelection = helpdesks.any((u) => u.id == _selectedAssignee);
        final selectedValue = hasValidSelection ? _selectedAssignee : null;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tindakan Admin (Status: Assign)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (hasError) ...[
                  Text(
                    'Error memuat helpdesk: ${ticketProvider.errorMessage}',
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                ] else if (helpdesks.isEmpty && !ticketProvider.isLoading) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Peringatan: Tidak ada petugas helpdesk aktif di database. Silakan ubah role user menjadi "helpdesk" di tabel profiles Supabase.',
                      style: TextStyle(color: Colors.orange, fontSize: 13, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                DropdownButtonFormField<String>(
                  value: selectedValue,
                  hint: Text(ticketProvider.isLoading 
                      ? 'Memuat petugas helpdesk...' 
                      : (helpdesks.isEmpty 
                          ? 'Tidak ada helpdesk aktif' 
                          : 'Pilih Petugas Helpdesk')),
                  decoration: const InputDecoration(
                    labelText: 'Petugas Helpdesk',
                    border: OutlineInputBorder(),
                  ),
                  items: helpdesks.map((user) {
                    return DropdownMenuItem(
                      value: user.id,
                      child: Text(user.name),
                    );
                  }).toList(),
                  onChanged: helpdesks.isEmpty ? null : (value) {
                    setState(() {
                      _selectedAssignee = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Assign Tiket',
                  onPressed: helpdesks.isEmpty ? null : () => _assignTicket(),
                ),
              ],
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    // 3. Status IN_PROGRESS -> Assigned Helpdesk or Admin can FINISH the ticket
    if (ticket.status == AppConstants.statusInProgress) {
      if (isAdmin || isAssignedHelpdesk) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isAdmin 
                      ? 'Tindakan Admin (Status: In Progress)' 
                      : 'Tindakan Helpdesk (Status: In Progress)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ditugaskan kepada: ${ticket.assignedToName ?? "Petugas"}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Selesaikan Pekerjaan (Finish)',
                  onPressed: _finishTicket,
                ),
              ],
            ),
          ),
        );
      }
      
      return Card(
        color: Colors.blue.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tiket sedang dikerjakan oleh: ${ticket.assignedToName ?? "Petugas"}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Status CLOSED -> Show final information
    if (ticket.status == AppConstants.statusClosed) {
      return Card(
        color: Colors.green.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tiket telah selesai dikerjakan oleh ${ticket.assignedToName ?? "Petugas"} dan ditutup.',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}