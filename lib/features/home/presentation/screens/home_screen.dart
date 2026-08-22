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
    final firstName = (authState.user?.fullName ?? 'vous').split(' ').first;

    final upcomingVisio = aptsState.upcoming
        .where((a) => _isVisio(a) && a.status == 'CONFIRMED')
        .toList();

    final nonVisioList = aptsState.upcoming.where((a) => !_isVisio(a)).toList();
    final nextApt = nonVisioList.isNotEmpty ? nonVisioList.first : null;

    final rawDate = DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now());
    final dateStr = rawDate[0].toUpperCase() + rawDate.substring(1);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Gradient header ──────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bonjour, $firstName 👋',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: () => context.go('/doctors'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Color(0xFF0D9488), size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Médecin, spécialité, ville...',
                                style: TextStyle(color: Colors.grey[500], fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Body ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (upcomingVisio.isNotEmpty) ...[
                    _VisioAppointmentBanner(appointments: upcomingVisio),
                    const SizedBox(height: 20),
                  ],

                  if (nextApt != null) ...[
                    _SectionHeader(
                      title: 'Prochain rendez-vous',
                      actionLabel: 'Tout voir',
                      onAction: () => context.go('/appointments'),
                    ),
                    const SizedBox(height: 10),
                    _NextAppointmentCard(
                      appointment: nextApt,
                      onTap: () => context.go('/appointments'),
                    ),
                    const SizedBox(height: 24),
                  ],

                  _SectionHeader(
                    title: 'Spécialités',
                    actionLabel: 'Voir tout',
                    onAction: () => context.go('/doctors'),
                  ),
                  const SizedBox(height: 14),
                  const _SpecialtyRow(),
                  const SizedBox(height: 24),

                  const _SectionHeader(title: 'Mes services', actionLabel: ''),
                  const SizedBox(height: 14),
                  const _ServicesGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, required this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        if (actionLabel.isNotEmpty && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel, style: const TextStyle(fontSize: 13, color: Color(0xFF0D9488), fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

// ─── Next appointment card ────────────────────────────────────────────────────

class _NextAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onTap;

  const _NextAppointmentCard({required this.appointment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final slot = appointment.slot;
    final doctorName = appointment.doctorName ?? 'Médecin';
    final dateStr = slot != null ? DateFormat('EEE d MMM', 'fr_FR').format(slot.start) : '';
    final timeStr = slot != null ? DateFormat('HH:mm').format(slot.start) : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D9488).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctorName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  if (appointment.kind != null)
                    Text(
                      appointment.kind!.name,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                    ),
                  if (dateStr.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 11, color: Colors.white.withValues(alpha: 0.8)),
                        const SizedBox(width: 4),
                        Text(
                          '$dateStr · $timeStr',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ─── Specialty row ────────────────────────────────────────────────────────────

class _SpecialtyRow extends StatelessWidget {
  const _SpecialtyRow();

  static const _items = [
    (Icons.favorite_rounded, 'Généraliste', Color(0xFFEF4444)),
    (Icons.psychology, 'Neurologue', Color(0xFF8B5CF6)),
    (Icons.remove_red_eye, 'Ophtalmo', Color(0xFF0EA5E9)),
    (Icons.child_care, 'Pédiatre', Color(0xFFF59E0B)),
    (Icons.spa, 'Gynéco', Color(0xFFEC4899)),
    (Icons.healing, 'Dermato', Color(0xFF22C55E)),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final (icon, label, color) = _items[i];
          return GestureDetector(
            onTap: () => context.go('/doctors'),
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 6),
                Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Services grid ────────────────────────────────────────────────────────────

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _ServiceCard(
          icon: Icons.calendar_today_rounded,
          label: 'Mes rendez-vous',
          color: const Color(0xFF0D9488),
          onTap: () => context.go('/appointments'),
        ),
        _ServiceCard(
          icon: Icons.folder_rounded,
          label: 'Dossier médical',
          color: const Color(0xFF0EA5E9),
          onTap: () => context.push('/health-records'),
        ),
        _ServiceCard(
          icon: Icons.description_rounded,
          label: 'Documents',
          color: const Color(0xFF8B5CF6),
          onTap: () => context.push('/documents'),
        ),
        _ServiceCard(
          icon: Icons.favorite_rounded,
          label: 'Mes favoris',
          color: const Color(0xFFEF4444),
          onTap: () => context.push('/favorites'),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Visio banner ─────────────────────────────────────────────────────────────

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
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
          ),
          if (timeStr.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              timeStr,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
