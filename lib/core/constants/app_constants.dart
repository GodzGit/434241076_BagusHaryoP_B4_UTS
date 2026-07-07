class AppConstants {
  // Route names
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeDashboard = '/dashboard';
  static const String routeTicketList = '/tickets';
  static const String routeTicketDetail = '/ticket/:id';
  static const String routeCreateTicket = '/create-ticket';
  static const String routeProfile = '/profile';

  // SharedPreferences keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Role types
  static const String roleUser = 'user';
  static const String roleHelpdesk = 'helpdesk';
  static const String roleAdmin = 'admin';

  // Ticket status
  static const String statusOpen = 'open';
  static const String statusAssign = 'assign';
  static const String statusInProgress = 'in_progress';
  static const String statusClosed = 'closed';
}