import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/ticket_provider.dart';
import 'providers/theme_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/ticket_list_screen.dart';
import 'presentation/screens/ticket_detail_screen.dart';
import 'presentation/screens/create_ticket_screen.dart';
import 'presentation/screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'E-Ticketing Helpdesk',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: AppConstants.routeSplash,
            routes: {
              AppConstants.routeSplash: (context) => const SplashScreen(),
              AppConstants.routeLogin: (context) => const LoginScreen(),
              AppConstants.routeRegister: (context) => const RegisterScreen(),
              AppConstants.routeDashboard: (context) => const DashboardScreen(),
              AppConstants.routeTicketList: (context) => const TicketListScreen(),
              AppConstants.routeTicketDetail: (context) => const TicketDetailScreen(),
              AppConstants.routeCreateTicket: (context) => const CreateTicketScreen(),
              AppConstants.routeProfile: (context) => const ProfileScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == AppConstants.routeTicketDetail) {
                return MaterialPageRoute(
                  builder: (context) => const TicketDetailScreen(),
                  settings: settings,
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}