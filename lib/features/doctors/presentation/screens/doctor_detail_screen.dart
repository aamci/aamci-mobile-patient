import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/doctor_model.dart';
import '../../data/models/slot_model.dart';
import '../providers/doctors_provider.dart';

class DoctorDetailScreen extends ConsumerStatefulWidget {
  final DoctorModel doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  ConsumerState<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends ConsumerState<DoctorDetailScreen> {
  String? _selectedDateKey; // "YYYY-MM-DD"
  SlotModel? _selectedSlot;

  String _localDateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _dateLabelShort(DateTime dt) {
    final today = DateTime.now();
    final todayKey = _localDateKey(today);
    final dtKey = _localDateKey(dt);
    if (dtKey == todayKey) return 'Auj.';
    final tomorrow = today.add(const Duration(days: 1));
    if (dtKey == _localDateKey(tomorrow)) return 'Dem.';
    const days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    return days[dt.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final slotsAsync = ref.watch(doctorSlotsProvider(widget.doctor.id));
    final slots = slotsAsync.valueOrNull ?? [];

    // Unique dates with available slots (deduplicated)
    final seenKeys = <String>{};
    final uniqueDates = <DateTime>[];
    for (final s in slots) {
      final key = _localDateKey(s.start);
      if (seenKeys.add(key)) {
        uniqueDates.add(DateTime(s.start.year, s.start.month, s.start.day));
      }
    }
    uniqueDates.sort();

    // Slots for selected date (deduplicated by start time)
    final seenSlots = <String>{};
    final daySlots = _selectedDateKey == null
        ? <SlotModel>[]
        : slots.where((s) {
            final k = _localDateKey(s.start);
            if (k != _selectedDateKey) return false;
            return seenSlots.add(s.start.toIso8601String());
          }).toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Dr. ${widget.doctor.displayName}'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDoctorCard(context),
                  _buildAboutSection(context),
                  _buildDateSelector(context, uniqueDates, slotsAsync),
                  if (_selectedDateKey != null)
                    _buildSlotsGrid(context, daySlots, slotsAsync),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    widget.doctor.displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${widget.doctor.displayName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.doctor.specialty,
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    if (widget.doctor.displayCity.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 2),
                          Text(
                            widget.doctor.displayCity,
                            style: TextStyle(color: Colors.grey[500], fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Rating row
          Row(
            children: [
              ...List.generate(5, (i) => Icon(
                i < 4 ? Icons.star : Icons.star_half,
                size: 16,
                color: const Color(0xFFF59E0B),
              )),
              const SizedBox(width: 6),
              Text(
                '4.8',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Badges
          Row(
            children: [
              _buildBadge(context, Icons.person_add_outlined, 'Nouveaux patients', const Color(0xFF0D9488)),
              const SizedBox(width: 8),
              _buildBadge(context, Icons.language, 'Français', const Color(0xFF6366F1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final profile = widget.doctor.doctorProfile;
    final hasPresentation = profile?.presentation != null && profile!.presentation!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasPresentation) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'À propos',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                profile.presentation!,
                style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Prix de la consultation',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF475569),
                  ),
                ),
                Text(
                  'Sur demande',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    List<DateTime> uniqueDates,
    AsyncValue<List<SlotModel>> slotsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: const Text(
            'Choisissez une date',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        if (slotsAsync.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (uniqueDates.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Aucune disponibilité dans les prochains jours',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          )
        else
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: uniqueDates.length,
              itemBuilder: (context, index) {
                final date = uniqueDates[index];
                final key = _localDateKey(date);
                final isSelected = _selectedDateKey == key;
                final primary = Theme.of(context).colorScheme.primary;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedDateKey = key;
                    _selectedSlot = null;
                  }),
                  child: Container(
                    width: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? primary : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? primary : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _dateLabelShort(date),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSlotsGrid(BuildContext context, List<SlotModel> daySlots, AsyncValue<List<SlotModel>> slotsAsync) {
    if (slotsAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Créneaux disponibles',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          if (daySlots.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Aucun créneau disponible ce jour',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: daySlots.length,
              itemBuilder: (context, index) {
                final slot = daySlots[index];
                final isSelected = _selectedSlot?.start == slot.start;
                final primary = Theme.of(context).colorScheme.primary;
                final timeStr = DateFormat('HH:mm').format(slot.start);
                return GestureDetector(
                  onTap: () => setState(() => _selectedSlot = slot),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? primary : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? primary : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        timeStr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isSelected ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final hasSlot = _selectedSlot != null;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasSlot)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: primary),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('EEEE d MMMM, HH:mm', 'fr_FR').format(_selectedSlot!.start),
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hasSlot
                  ? () {
                      context.push('/booking', extra: {
                        'doctor': widget.doctor,
                        'slot': _selectedSlot!,
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(hasSlot ? 'Continuer' : 'Sélectionnez un créneau'),
            ),
          ),
        ],
      ),
    );
  }
}
