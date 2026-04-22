import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../widgets/ticket_card.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({Key? key}) : super(key: key);

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await ticketProvider.loadTickets(authProvider.currentUser!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredTickets(TicketProvider provider) {
    final tickets = provider.tickets;
    
    switch (_selectedStatus) {
      case AppConstants.statusOpen:
        return tickets.where((t) => t.status == AppConstants.statusOpen).toList();
      case AppConstants.statusInProgress:
        return tickets.where((t) => t.status == AppConstants.statusInProgress).toList();
      case AppConstants.statusResolved:
        return tickets.where((t) => t.status == AppConstants.statusResolved).toList();
      case AppConstants.statusClosed:
        return tickets.where((t) => t.status == AppConstants.statusClosed).toList();
      default:
        return tickets;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);
    final user = authProvider.currentUser;
    final filteredTickets = _getFilteredTickets(ticketProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tiket'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (index) {
            setState(() {
              switch (index) {
                case 0:
                  _selectedStatus = 'semua';
                  break;
                case 1:
                  _selectedStatus = AppConstants.statusOpen;
                  break;
                case 2:
                  _selectedStatus = AppConstants.statusInProgress;
                  break;
                case 3:
                  _selectedStatus = AppConstants.statusResolved;
                  break;
                case 4:
                  _selectedStatus = AppConstants.statusClosed;
                  break;
              }
            });
          },
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Open'),
            Tab(text: 'Progress'),
            Tab(text: 'Resolved'),
            Tab(text: 'Closed'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ticketProvider.isLoading && ticketProvider.tickets.isEmpty
            ? const LoadingIndicator(message: 'Memuat tiket...')
            : filteredTickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada tiket',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (user?.role == AppConstants.roleUser)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppConstants.routeCreateTicket,
                              );
                            },
                            child: const Text('Buat Tiket Baru'),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = filteredTickets[index];
                      return TicketCard(
                        ticket: ticket,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppConstants.routeTicketDetail,
                            arguments: ticket.id,
                          );
                        },
                      );
                    },
                  ),
      ),
      floatingActionButton: user?.role == AppConstants.roleUser
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppConstants.routeCreateTicket);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}