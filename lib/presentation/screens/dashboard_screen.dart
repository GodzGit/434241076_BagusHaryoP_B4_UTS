import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await ticketProvider.loadDashboardStats(authProvider.currentUser!.role);
      await ticketProvider.loadTickets(authProvider.currentUser!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);
    final user = authProvider.currentUser;
    final stats = ticketProvider.dashboardStats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppConstants.routeProfile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppConstants.routeLogin);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
        },
        child: ticketProvider.isLoading && stats == null
            ? const LoadingIndicator(message: 'Memuat data...')
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, ${user?.name ?? "User"}!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user?.role == AppConstants.roleAdmin
                                  ? 'Administrator'
                                  : user?.role == AppConstants.roleHelpdesk
                                      ? 'Petugas Helpdesk'
                                      : 'Pengguna',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Statistics Section
                    Text(
                      'Statistik Tiket',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          context,
                          'Total Tiket',
                          stats?['total']?.toString() ?? '0',
                          Icons.confirmation_number,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          context,
                          'Open',
                          stats?['open']?.toString() ?? '0',
                          Icons.pending_actions,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          context,
                          'In Progress',
                          stats?['inProgress']?.toString() ?? '0',
                          Icons.sync,
                          Colors.purple,
                        ),
                        _buildStatCard(
                          context,
                          'Resolved',
                          stats?['resolved']?.toString() ?? '0',
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    Text(
                      'Aksi Cepat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            context,
                            'Buat Tiket Baru',
                            Icons.add_circle,
                            Colors.green,
                            () {
                              Navigator.pushNamed(
                                context,
                                AppConstants.routeCreateTicket,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            context,
                            'Lihat Tiket',
                            Icons.list_alt,
                            Colors.blue,
                            () {
                              Navigator.pushNamed(
                                context,
                                AppConstants.routeTicketList,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Tickets (Preview)
                    if (ticketProvider.tickets.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiket Terbaru',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppConstants.routeTicketList,
                              );
                            },
                            child: const Text('Lihat Semua'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ticketProvider.tickets.length > 3
                            ? 3
                            : ticketProvider.tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = ticketProvider.tickets[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(ticket.status),
                                child: Icon(
                                  _getStatusIcon(ticket.status),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                ticket.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${ticket.statusText} • ${ticket.createdAt}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppConstants.routeTicketDetail,
                                  arguments: ticket.id,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
      ),
      floatingActionButton: user?.role == AppConstants.roleUser
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, AppConstants.routeCreateTicket);
              },
              icon: const Icon(Icons.add),
              label: const Text('Tiket Baru'),
            )
          : null,
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case AppConstants.statusOpen:
        return Icons.pending;
      case AppConstants.statusInProgress:
        return Icons.sync;
      case AppConstants.statusResolved:
        return Icons.check;
      case AppConstants.statusClosed:
        return Icons.close;
      default:
        return Icons.help;
    }
  }
}