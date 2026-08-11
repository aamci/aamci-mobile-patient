import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/appointment_model.dart';
import '../providers/appointments_provider.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => ref.read(appointmentsProvider.notifier).load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes rendez-vous'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Passés'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _AppointmentList(
                  appointments: state.upcoming,
                  emptyMessage: 'Aucun rendez-vous à venir',
                  emptyIcon: Icons.calendar_today,
                  onRefresh: () => ref.read(appointmentsProvider.notifier).load(),
                  onCancel: (id) => _cancelAppointment(id),
                ),
                _AppointmentList(
                  appointments: state.past,
                  emptyMessage: 'Aucun rendez-vous passé',
                  emptyIcon: Icons.history,
                  onRefresh: () => ref.read(appointmentsProvider.notifier).load(),
                  onRate: (apt) => _showRatingSheet(apt),
                ),
              ],
            ),
    );
  }

  Future<void> _cancelAppointment(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler le rendez-vous'),
        content: const Text('Voulez-vous vraiment annuler ce rendez-vous ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref.read(appointmentsProvider.notifier).cancel(id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Rendez-vous annulé' : 'Erreur lors de l\'annulation'),
      backgroundColor: success ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
    ));
  }

  void _showRatingSheet(AppointmentModel appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RatingSheet(
        appointment: appointment,
        onSubmit: (data) async {
          final apiClient = ref.read(apiClientProvider);
          try {
            await apiClient.post(ApiEndpoints.reviews, data: data);
            if (!mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Merci pour votre avis !'),
              backgroundColor: Color(0xFF22C55E),
            ));
          } catch (_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Erreur lors de l\'envoi de l\'avis'),
              backgroundColor: Color(0xFFEF4444),
            ));
          }
        },
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final String emptyMessage;
  final IconData emptyIcon;
  final Future<void> Function() onRefresh;
  final void Function(String)? onCancel;
  final void Function(AppointmentModel)? onRate;

  const _AppointmentList({
    required this.appointments,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.onRefresh,
    this.onCancel,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final apt = appointments[index];
          return _AppointmentCard(
            appointment: apt,
            onCancel: onCancel != null && apt.status != 'CANCELLED'
                ? () => onCancel!(apt.id)
                : null,
            onRate: onRate != null && apt.status == 'COMPLETED'
                ? () => onRate!(apt)
                : null,
          );
        },
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onRate;

  const _AppointmentCard({required this.appointment, this.onCancel, this.onRate});

  bool get _isVisio {
    final name = (appointment.kind?.name ?? appointment.type).toLowerCase();
    return name.contains('visio') ||
        name.contains('téléconsultation') ||
        name.contains('teleconsultation') ||
        name.contains('video') ||
        name.contains('vidéo');
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return const Color(0xFF22C55E);
      case 'PENDING':
        return const Color(0xFFF59E0B);
      case 'CANCELLED':
        return const Color(0xFFEF4444);
      case 'COMPLETED':
        return const Color(0xFF2563EB);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final slot = appointment.slot;
    final dateStr = slot != null
        ? DateFormat('EEE d MMM yyyy', 'fr_FR').format(slot.start)
        : '';
    final timeStr = slot != null
        ? '${DateFormat('HH:mm').format(slot.start)} - ${DateFormat('HH:mm').format(slot.end)}'
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appointment.kind?.name ?? 'Consultation',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(appointment.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.statusLabel,
                    style: TextStyle(
                      color: _statusColor(appointment.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (slot != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14),
                  const SizedBox(width: 6),
                  Text(dateStr, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 14),
                  const SizedBox(width: 6),
                  Text(timeStr, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ],
            if (_isVisio && appointment.status == 'CONFIRMED') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push(
                    '/teleconsultation/${appointment.id}',
                    extra: {'doctorName': appointment.doctorName},
                  ),
                  icon: const Icon(Icons.videocam, size: 18),
                  label: const Text('Rejoindre la visio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
            if (onCancel != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Annuler'),
                ),
              ),
            ],
            if (onRate != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRate,
                  icon: const Icon(Icons.star_outline, size: 18),
                  label: const Text('Laisser un avis'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF59E0B),
                    side: const BorderSide(color: Color(0xFFF59E0B)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RatingSheet extends StatefulWidget {
  final AppointmentModel appointment;
  final Future<void> Function(Map<String, dynamic>) onSubmit;

  const _RatingSheet({required this.appointment, required this.onSubmit});

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  int _overallRating = 0;
  int _punctualityRating = 0;
  int _communicationRating = 0;
  final _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_overallRating == 0 || _punctualityRating == 0 || _communicationRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez noter tous les critères'),
        backgroundColor: Color(0xFFF59E0B),
      ));
      return;
    }
    setState(() => _isSubmitting = true);
    final doctorId = widget.appointment.slot?.ownerId ??
        widget.appointment.doctor?.id ??
        '';
    await widget.onSubmit({
      'doctorId': doctorId,
      'overallRating': _overallRating,
      'punctualityRating': _punctualityRating,
      'communicationRating': _communicationRating,
      'comment': _commentCtrl.text.trim(),
    });
    if (mounted) setState(() => _isSubmitting = false);
  }

  Widget _starRow(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Row(
          children: List.generate(5, (i) {
            final starIndex = i + 1;
            return GestureDetector(
              onTap: () => onChanged(starIndex),
              child: Icon(
                starIndex <= value ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 34,
                color: starIndex <= value ? const Color(0xFFF59E0B) : Colors.grey[300],
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Laisser un avis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (widget.appointment.doctorName != null) ...[
              const SizedBox(height: 4),
              Text(
                'Dr ${widget.appointment.doctorName}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 20),
            _starRow(
              'Note globale',
              _overallRating,
              (v) => setState(() => _overallRating = v),
            ),
            const SizedBox(height: 16),
            _starRow(
              'Ponctualité',
              _punctualityRating,
              (v) => setState(() => _punctualityRating = v),
            ),
            const SizedBox(height: 16),
            _starRow(
              'Communication',
              _communicationRating,
              (v) => setState(() => _communicationRating = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Commentaire (optionnel)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Envoyer mon avis'),
            ),
          ],
        ),
      ),
    );
  }
}
