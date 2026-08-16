import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/appointment_model.dart';
import '../providers/appointments_provider.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AppointmentDetailScreen extends ConsumerWidget {
  final AppointmentModel appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final slot = appointment.slot;
    final dateStr = slot != null
        ? DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(slot.start)
        : null;
    final timeStr = slot != null
        ? '${DateFormat('HH:mm').format(slot.start)} – ${DateFormat('HH:mm').format(slot.end)}'
        : null;
    final duration = slot != null
        ? slot.end.difference(slot.start).inMinutes
        : appointment.kind?.durationMins;

    return Scaffold(
      appBar: AppBar(title: const Text('Détail du rendez-vous')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _statusColor(appointment.status).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _statusColor(appointment.status).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _statusIcon(appointment.status),
                  color: _statusColor(appointment.status),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.statusLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: _statusColor(appointment.status),
                      ),
                    ),
                    Text(
                      appointment.kind?.name ?? 'Consultation',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Doctor info
          _InfoCard(
            icon: Icons.person_outlined,
            label: 'Médecin',
            value: appointment.doctorName != null
                ? 'Dr ${appointment.doctorName}'
                : 'Non renseigné',
          ),

          // Date & time
          if (dateStr != null) ...[
            _InfoCard(icon: Icons.calendar_today_outlined, label: 'Date', value: dateStr),
            _InfoCard(icon: Icons.access_time_outlined, label: 'Horaire', value: timeStr ?? ''),
          ],

          // Duration
          if (duration != null && duration > 0)
            _InfoCard(
              icon: Icons.timer_outlined,
              label: 'Durée',
              value: '$duration min',
            ),

          // Price
          if (appointment.kind?.price != null && appointment.kind!.price! > 0)
            _InfoCard(
              icon: Icons.payments_outlined,
              label: 'Tarif',
              value: '${appointment.kind!.price!.toStringAsFixed(0)} FCFA',
            ),

          // Location (facility)
          if (appointment.facilityName != null)
            _InfoCard(
              icon: Icons.location_on_outlined,
              label: 'Cabinet / Établissement',
              value: [appointment.facilityName, appointment.facilityAddress]
                  .where((s) => s != null && s.isNotEmpty)
                  .join('\n'),
            ),

          // Instructions (kind description)
          if (appointment.kind?.description != null && appointment.kind!.description!.isNotEmpty)
            _InfoCard(
              icon: Icons.info_outline,
              label: 'Consignes',
              value: appointment.kind!.description!,
            ),

          // Patient notes
          if (appointment.notes != null && appointment.notes!.isNotEmpty)
            _InfoCard(
              icon: Icons.notes_outlined,
              label: 'Notes',
              value: appointment.notes!,
            ),

          // Ref
          _InfoCard(
            icon: Icons.tag_outlined,
            label: 'Référence',
            value: appointment.id.substring(0, 8).toUpperCase(),
          ),

          const SizedBox(height: 24),

          // Visio button
          if (_isVisio && appointment.status == 'CONFIRMED')
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                onPressed: () => context.push(
                  '/teleconsultation/${appointment.id}',
                  extra: {'doctorName': appointment.doctorName},
                ),
                icon: const Icon(Icons.videocam),
                label: const Text('Rejoindre la visio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

          // Rate button
          if (appointment.status == 'COMPLETED')
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton.icon(
                onPressed: () => _showRatingSheet(context, ref),
                icon: const Icon(Icons.star_outline),
                label: const Text('Laisser un avis'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF59E0B),
                  side: const BorderSide(color: Color(0xFFF59E0B)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

          // Cancel button
          if (appointment.status != 'CANCELLED' && appointment.status != 'COMPLETED')
            OutlinedButton.icon(
              onPressed: () => _cancelAppointment(context, ref),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Annuler le rendez-vous'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ],
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Icons.check_circle_outline;
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'CANCELLED':
        return Icons.cancel_outlined;
      case 'COMPLETED':
        return Icons.task_alt;
      default:
        return Icons.info_outline;
    }
  }

  Future<void> _cancelAppointment(BuildContext context, WidgetRef ref) async {
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

    if (confirmed != true) return;

    final success = await ref.read(appointmentsProvider.notifier).cancel(appointment.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Rendez-vous annulé' : 'Erreur lors de l\'annulation'),
        backgroundColor: success ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
      ));
      if (success) context.pop();
    }
  }

  void _showRatingSheet(BuildContext context, WidgetRef ref) {
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
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Merci pour votre avis !'),
                backgroundColor: Color(0xFF22C55E),
              ));
            }
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Erreur lors de l\'envoi de l\'avis'),
                backgroundColor: Color(0xFFEF4444),
              ));
            }
          }
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[500]),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
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
    final doctorId = widget.appointment.slot?.ownerId ?? widget.appointment.doctor?.id ?? '';
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
            final star = i + 1;
            return GestureDetector(
              onTap: () => onChanged(star),
              child: Icon(
                star <= value ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 34,
                color: star <= value ? const Color(0xFFF59E0B) : Colors.grey[300],
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
            Text('Laisser un avis',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            if (widget.appointment.doctorName != null) ...[
              const SizedBox(height: 4),
              Text('Dr ${widget.appointment.doctorName}',
                  style: TextStyle(color: Colors.grey[600])),
            ],
            const SizedBox(height: 20),
            _starRow('Note globale', _overallRating, (v) => setState(() => _overallRating = v)),
            const SizedBox(height: 16),
            _starRow('Ponctualité', _punctualityRating, (v) => setState(() => _punctualityRating = v)),
            const SizedBox(height: 16),
            _starRow('Communication', _communicationRating, (v) => setState(() => _communicationRating = v)),
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
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Envoyer mon avis'),
            ),
          ],
        ),
      ),
    );
  }
}
