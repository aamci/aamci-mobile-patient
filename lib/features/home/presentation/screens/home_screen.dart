import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../appointments/presentation/providers/appointments_provider.dart';
import '../../../appointments/data/models/appointment_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(appointmentsProvider.notifier).load());
  }

  bool _isVisio(AppointmentModel apt) {
    final name = (apt.kind?.name ?? apt.type).toLowerCase();
    return name.contains('visio') ||
        name.contains('téléconsultation') ||
        name.contains('teleconsultation') ||
        name.contains('video') ||
        name.contains('vidéo');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final aptsState = ref.watch(appointmentsProvider);
    final userName = authState.user?.fullName ?? 'Patient';

    final upcomingVisio = aptsState.upcoming
        .where((a) => _isVisio(a) && a.status == 'CONFIRMED')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Platform'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, $userName',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comment allez-vous aujourd\'hui ?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // Upcoming visio banner
            if (upcomingVisio.isNotEmpty) ...[
              _VisioAppointmentBanner(appointments: upcomingVisio),
              const SizedBox(height: 20),
            ],

            Card(
              child: ListTile(
                leading: const Icon(Icons.search, color: Color(0xFF0D9488)),
                title: const Text('Trouver un médecin'),
                subtitle: const Text('Recherchez par spécialité ou nom'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/doctors'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFF0D9488)),
                title: const Text('Mes rendez-vous'),
                subtitle: const Text('Consultez vos prochains RDV'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/appointments'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.videocam_outlined, color: Color(0xFF7C3AED)),
                title: const Text('Téléconsultation'),
                subtitle: const Text('Rejoignez une consultation vidéo'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/appointments'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.folder_outlined, color: Color(0xFF0D9488)),
                title: const Text('Dossier médical'),
                subtitle: const Text('Accédez à votre historique'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/health-records'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.favorite_outline, color: Color(0xFF0D9488)),
                title: const Text('Mes favoris'),
                subtitle: const Text('Médecins enregistrés'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/favorites'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.description_outlined, color: Color(0xFF0D9488)),
                title: const Text('Documents médicaux'),
                subtitle: const Text('Ordonnances, résultats...'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/documents'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisioAppointmentBanner extends StatelessWidget {
  final List<AppointmentModel> appointments;

  const _VisioAppointmentBanner({required this.appointments});

  @override
  Widget build(BuildContext context) {
    final next = appointments.first;
    final doctorName = next.doctorName ?? 'votre médecin';
    final slotStart = next.slot?.start;
    final timeStr = slotStart != null
        ? DateFormat('EEE d MMM à HH:mm', 'fr_FR').format(slotStart)
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.videocam, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Téléconsultation à venir',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              if (appointments.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${appointments.length - 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Avec $doctorName',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          if (timeStr.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              timeStr,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push(
                '/teleconsultation/${next.id}',
                extra: {'doctorName': next.doctorName},
              ),
              icon: const Icon(Icons.videocam, size: 18),
              label: const Text('Rejoindre la visio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
