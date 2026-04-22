import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../widgets/comment_item.dart';

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({Key? key}) : super(key: key);

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _commentController = TextEditingController();
  String? _selectedNewStatus;
  String? _selectedAssignee;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ticketId = ModalRoute.of(context)?.settings.arguments as String;
    if (ticketId != null) {
      _loadTicketDetail(ticketId);
    }
  }

  Future<void> _loadTicketDetail(String ticketId) async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    await ticketProvider.loadTicketDetail(ticketId);
    
    if (ticketProvider.currentTicket != null) {
      setState(() {
        _selectedNewStatus = ticketProvider.currentTicket!.status;
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

  Future<void> _updateStatus() async {
    if (_selectedNewStatus == null) return;

    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final ticket = ticketProvider.currentTicket;

    if (ticket != null && _selectedNewStatus != ticket.status) {
      final success = await ticketProvider.updateTicketStatus(
        ticket.id,
        _selectedNewStatus!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status berhasil diubah menjadi ${_getStatusText(_selectedNewStatus!)}'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ticketProvider.errorMessage ?? 'Gagal mengubah status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _assignTicket() async {
    if (_selectedAssignee == null || _selectedAssignee!.isEmpty) return;

    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final ticket = ticketProvider.currentTicket;

    if (ticket != null) {
      final success = await ticketProvider.assignTicket(
        ticket.id,
        _selectedAssignee!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiket berhasil diassign'),
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

  String _getStatusText(String status) {
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

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusOpen:
        return Colors.orange;
      case AppConstants.statusInProgress:
        return Colors.blue;
      case AppConstants.statusResolved:
        return Colors.green;
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
    final isAdminOrHelpdesk = authProvider.currentUser?.isAdminOrHelpdesk ?? false;

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
                                    'Dibuat: ${ticket.createdAt}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              if (ticket.assignedTo != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.person_add, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Assign ke: ${ticket.assignedTo}',
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

                      // Admin/Helpdesk Actions
                      if (isAdminOrHelpdesk) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Aksi Admin',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Update Status
                                DropdownButtonFormField<String>(
                                  value: _selectedNewStatus,
                                  decoration: const InputDecoration(
                                    labelText: 'Update Status',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
                                    AppConstants.statusOpen,
                                    AppConstants.statusInProgress,
                                    AppConstants.statusResolved,
                                    AppConstants.statusClosed,
                                  ].map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(_getStatusText(status)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedNewStatus = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                CustomButton(
                                  text: 'Update Status',
                                  onPressed: _updateStatus,
                                ),
                                const SizedBox(height: 16),
                                // Assign Ticket
                                TextFormField(
                                  initialValue: _selectedAssignee,
                                  decoration: const InputDecoration(
                                    labelText: 'Assign ke (nama helpdesk)',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedAssignee = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                CustomButton(
                                  text: 'Assign Tiket',
                                  onPressed: _assignTicket,
                                  isOutlined: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

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
}