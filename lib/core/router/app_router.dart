import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/doctors/presentation/screens/doctors_screen.dart';
import '../../features/doctors/presentation/screens/doctor_detail_screen.dart';
import '../../features/doctors/presentation/screens/booking_screen.dart';
import '../../features/doctors/data/models/doctor_model.dart';
import '../../features/doctors/data/models/slot_model.dart';
import '../../features/appointments/presentation/screens/appointments_screen.dart';
import '../../features/appointments/presentation/screens/appointment_detail_screen.dart';
import '../../features/appointments/data/models/appointment_model.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/messages/presentation/screens/conversations_screen.dart';
import '../../features/messages/presentation/screens/conversation_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/health_records/presentation/screens/health_records_screen.dart';
import '../../features/documents/presentation/screens/documents_screen.dart';
import '../../features/facilities/presentation/screens/facilities_screen.dart';
import '../../features/facilities/presentation/screens/facility_detail_screen.dart';
import '../../features/teleconsultation/presentation/screens/teleconsultation_screen.dart';
import '../../features/privacy/presentation/screens/privacy_screen.dart';
import '../../features/privacy/presentation/screens/terms_screen.dart';
import '../../features/insurance/presentation/screens/insurance_screen.dart';
import '../../features/emergency_contacts/presentation/screens/emergency_contacts_screen.dart';
import '../../features/invoices/presentation/screens/invoices_screen.dart';
import '../../features/consents/presentation/screens/consents_screen.dart';
import 'shell_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isOnSplash = state.matchedLocation == '/splash';
      final isLoggingIn = state.matchedLocation == '/login';

      if (authState.status == AuthStatus.initial || authState.status == AuthStatus.loading) {
        return isOnSplash ? null : '/splash';
      }

      final isRegistering = state.matchedLocation == '/register';
      if (!isAuthenticated && !isLoggingIn && !isRegistering) return '/login';
      if (isAuthenticated && (isLoggingIn || isOnSplash || isRegistering)) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(token: token);
        },
      ),
      GoRoute(
        path: '/doctor/:id',
        builder: (context, state) {
          final doctor = state.extra as DoctorModel;
          return DoctorDetailScreen(doctor: doctor);
        },
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BookingScreen(
            doctor: extra['doctor'] as DoctorModel,
            slot: extra['slot'] as SlotModel,
          );
        },
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/health-records',
        builder: (context, state) => const HealthRecordsScreen(),
      ),
      GoRoute(
        path: '/documents',
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: '/facilities',
        builder: (context, state) => const FacilitiesScreen(),
      ),
      GoRoute(
        path: '/facility/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final facility = state.extra as Map<String, dynamic>?;
          return FacilityDetailScreen(facilityId: id, facilityData: facility);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/conversation/:id',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ConversationDetailScreen(
            conversationId: state.pathParameters['id']!,
            participantName: extra['name'] as String? ?? 'Conversation',
            participantId: extra['participantId'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/insurance',
        builder: (context, state) => const InsuranceScreen(),
      ),
      GoRoute(
        path: '/emergency-contacts',
        builder: (context, state) => const EmergencyContactsScreen(),
      ),
      GoRoute(
        path: '/invoices',
        builder: (context, state) => const InvoicesScreen(),
      ),
      GoRoute(
        path: '/consents',
        builder: (context, state) => const ConsentsScreen(),
      ),
      GoRoute(
        path: '/teleconsultation/:appointmentId',
        builder: (context, state) {
          final appointmentId = state.pathParameters['appointmentId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return TeleconsultationScreen(
            appointmentId: appointmentId,
            doctorName: extra?['doctorName'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/appointments/:id',
        builder: (context, state) {
          final appointment = state.extra as AppointmentModel;
          return AppointmentDetailScreen(appointment: appointment);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/doctors',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DoctorsScreen(),
            ),
          ),
          GoRoute(
            path: '/appointments',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AppointmentsScreen(),
            ),
          ),
          GoRoute(
            path: '/messages',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ConversationsScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
