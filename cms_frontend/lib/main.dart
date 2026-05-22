import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'features/layout/main_layout.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/stations/screens/stations_screen.dart';
import 'features/stations/screens/hubs_screen.dart';
import 'features/stations/screens/station_detail_screen.dart';
import 'features/chargers/screens/chargers_screen.dart';
import 'features/chargers/screens/charger_detail_screen.dart';
import 'features/chargers/screens/charger_config_screen.dart';
import 'features/sessions/screens/sessions_screen.dart';
import 'features/payments/screens/payments_screen.dart';
import 'features/alerts/screens/alerts_screen.dart';
import 'features/bookings/screens/bookings_screen.dart';
import 'features/users/screens/users_screen.dart';
import 'features/users/screens/user_detail_screen.dart';
import 'features/fleet/screens/fleet_screen.dart';
import 'features/analytics/screens/analytics_screen.dart';
import 'features/maps/screens/maps_screen.dart';
import 'features/support/screens/support_screen.dart';
import 'features/ai_monitoring/screens/ai_monitoring_screen.dart';
import 'features/reports/screens/reports_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/settings/screens/vendor_onboarding_wizard.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/notifications/notification_provider.dart';
import 'features/vendor_dashboard/screens/vendor_layout.dart';
import 'features/vendor_dashboard/screens/vendor_overview_screen.dart';
import 'features/vendor_dashboard/screens/vendor_stations_screen.dart';
import 'features/vendor_dashboard/screens/vendor_bookings_screen.dart';
import 'features/vendor_dashboard/screens/vendor_payments_screen.dart';
import 'features/vendor_dashboard/screens/vendor_settings_screen.dart';
import 'features/vendor_dashboard/screens/vendor_charging_screen.dart';
import 'features/vendor_dashboard/screens/vendor_sessions_screen.dart';
import 'features/landing/screens/landing_screen.dart';

import 'features/auth/screens/sign_in_screen.dart';
import 'features/auth/screens/vendor_registration_screen.dart';
import 'features/auth/screens/verification_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  assert(Config.supabaseUrl.isNotEmpty, 'SUPABASE_URL must be provided via --dart-define.');
  assert(Config.supabaseAnonKey.isNotEmpty, 'SUPABASE_ANON_KEY must be provided via --dart-define.');

  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
  );
  
  runApp(const EVCMSApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const VendorRegistrationScreen(),
    ),
    GoRoute(
      path: '/verify',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return VerificationScreen(email: email);
      },
    ),
    GoRoute(
      path: '/vendor-dashboard',
      builder: (context, state) => const VendorLayout(child: VendorOverviewScreen()),
    ),
    GoRoute(
      path: '/vendor-dashboard/charging',
      builder: (context, state) => const VendorLayout(child: VendorChargingScreen()),
    ),
    GoRoute(
      path: '/vendor-dashboard/stations',
      builder: (context, state) => const VendorLayout(child: VendorStationsScreen()),
    ),
    GoRoute(
      path: '/vendor-dashboard/sessions',
      builder: (context, state) => const VendorLayout(child: VendorSessionsScreen()),
    ),
    GoRoute(
      path: '/vendor-dashboard/bookings',
      builder: (context, state) => const VendorLayout(child: VendorBookingsScreen()),
    ),
    GoRoute(
      path: '/vendor-dashboard/payments',
      builder: (context, state) => const VendorLayout(child: VendorPaymentsScreen()),
    ),
    GoRoute(
      path: '/vendor-dashboard/settings',
      builder: (context, state) => const VendorLayout(child: VendorSettingsScreen()),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
        GoRoute(path: '/hubs', builder: (context, state) => const HubsScreen()),
        GoRoute(path: '/stations', builder: (context, state) => const StationsScreen()),
        GoRoute(
          path: '/stations/:id',
          builder: (context, state) {
            final stationId = state.pathParameters['id']!;
            return StationDetailScreen(stationId: stationId);
          },
        ),
        GoRoute(
          path: '/chargers/:id',
          builder: (context, state) {
            final chargerId = state.pathParameters['id']!;
            return ChargerDetailScreen(chargerId: chargerId);
          },
        ),
        GoRoute(path: '/chargers', builder: (context, state) => const ChargersScreen()),
        GoRoute(path: '/onboarding', builder: (context, state) => const ChargerConfigScreen()),
        GoRoute(path: '/vendor-portal', builder: (context, state) => const VendorOnboardingWizard()),
        GoRoute(path: '/sessions', builder: (context, state) => const SessionsScreen()),
        GoRoute(path: '/alerts', builder: (context, state) => const AlertsScreen()),
        GoRoute(path: '/bookings', builder: (context, state) => const BookingsScreen()),
        GoRoute(path: '/users', builder: (context, state) => const UsersScreen()),
        GoRoute(
          path: '/users/:id',
          builder: (context, state) {
            final userId = state.pathParameters['id']!;
            return UserDetailScreen(userId: userId);
          },
        ),
        GoRoute(path: '/fleet', builder: (context, state) => const FleetScreen()),
        GoRoute(path: '/payments', builder: (context, state) => const PaymentsScreen()),
        GoRoute(path: '/analytics', builder: (context, state) => const AnalyticsScreen()),
        GoRoute(path: '/maps', builder: (context, state) => const MapsScreen()),
        GoRoute(path: '/alerts', builder: (context, state) => const AlertsScreen()),
        GoRoute(path: '/support', builder: (context, state) => const SupportScreen()),
        GoRoute(path: '/ai_monitoring', builder: (context, state) => const AIMonitoringScreen()),
        GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
      ],
    ),
  ],
);

class EVCMSApp extends StatelessWidget {
  const EVCMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationProvider(),
      child: MaterialApp.router(
        title: 'EV HUB',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0F0F0F),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4ADDA2), // Mint Green
            surface: Color(0xFF141414), // Dark Charcoal
          ),
          textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).copyWith(
            bodyMedium: GoogleFonts.plusJakartaSans(color: const Color(0xFF8A8A8A)),
          ),
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
