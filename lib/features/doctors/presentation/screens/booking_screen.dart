import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/doctor_model.dart';
import '../../data/models/slot_model.dart';
import '../../data/models/appointment_kind_model.dart';
import '../providers/doctors_provider.dart';
import '../../../appointments/presentation/providers/appointments_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final DoctorModel doctor;
  final SlotModel slot;

  const BookingScreen({
    super.key,
    required this.doctor,
    required this.slot,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int _step = 0; // 0=Pour qui, 1=Type+Motif, 2=Confirmation

  // Step 0: Pour qui
  String _bookingFor = 'me'; // 'me' | 'other'
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 1: Type + motif
  AppointmentKindModel? _selectedKind;
  final Set<String> _selectedChips = {};
  final _notesController = TextEditingController();

  // Submit state
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String get _stepTitle {
    switch (_step) {
      case 0:
        return 'Pour qui ?';
      case 1:
        return 'Type de consultation';
      case 2:
        return 'Confirmation';
      default:
        return '';
    }
  }

  void _goNext(List<AppointmentKindModel> kinds) {
    setState(() => _error = null);
    if (_step == 0) {
      if (_bookingFor == 'other' && _nameController.text.trim().isEmpty) {
        setState(() => _error = 'Veuillez renseigner le nom du bénéficiaire');
        return;
      }
      setState(() => _step = 1);
    } else if (_step == 1) {
      if (kinds.isNotEmpty && _selectedKind == null) {
        setState(() => _error = 'Veuillez sélectionner un type de consultation');
        return;
      }
      setState(() => _step = 2);
    } else {
      _confirm();
    }
  }

  void _goBack() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _step -= 1;
        _error = null;
      });
    }
  }

  Future<void> _confirm() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final notesParts = [
      _selectedChips.join(', '),
      _notesController.text.trim(),
    ].where((s) => s.isNotEmpty).join(' — ');

    final success = await ref.read(appointmentsProvider.notifier).book(
          doctorId: widget.doctor.id,
          slotStart: widget.slot.start,
          slotEnd: widget.slot.end,
          kindId: _selectedKind?.id,
          notes: notesParts.isEmpty ? null : notesParts,
          beneficiaryName:
              _bookingFor == 'other' ? _nameController.text.trim() : null,
          beneficiaryPhone:
              _bookingFor == 'other' ? _phoneController.text.trim() : null,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ref.invalidate(doctorSlotsProvider(widget.doctor.id));
      // Pop booking screen + doctor detail to go back to doctors list
      Navigator.of(context)
        ..pop() // booking
        ..pop(); // doctor detail
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rendez-vous réservé avec succès !'),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
    } else {
      setState(() => _error = 'Erreur lors de la réservation. Veuillez réessayer.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final kindsAsync = ref.watch(doctorKindsProvider(widget.doctor.id));
    final kinds = kindsAsync.valueOrNull ?? [];
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: BackButton(onPressed: _goBack),
        title: Text(_stepTitle),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / 3,
            backgroundColor: const Color(0xFFE2E8F0),
            color: primary,
            minHeight: 3,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Slot summary card (always visible)
                  _buildSlotCard(context, primary),
                  const SizedBox(height: 20),
                  // Step content
                  if (_step == 0) _buildStepPourQui(context, primary),
                  if (_step == 1) _buildStepTypeMotif(context, primary, kinds, kindsAsync),
                  if (_step == 2) _buildStepConfirmation(context, primary, kinds),
                  // Error
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _buildBottomBar(context, primary, kinds),
        ],
      ),
    );
  }

  Widget _buildSlotCard(BuildContext context, Color primary) {
    final dateStr = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(widget.slot.start);
    final timeStr = DateFormat('HH:mm').format(widget.slot.start);
    final endStr = DateFormat('HH:mm').format(widget.slot.end);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.calendar_today, color: primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. ${widget.doctor.displayName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateStr · $timeStr – $endStr',
                  style: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepPourQui(BuildContext context, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pour qui prenez-vous rendez-vous ?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        _buildForOption(
          context,
          primary,
          value: 'me',
          icon: Icons.person,
          title: 'Pour moi',
          subtitle: 'Réserver en mon nom',
        ),
        const SizedBox(height: 10),
        _buildForOption(
          context,
          primary,
          value: 'other',
          icon: Icons.people,
          title: "Pour quelqu'un d'autre",
          subtitle: 'Proche, famille...',
        ),
        if (_bookingFor == 'other') ...[
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nom complet du bénéficiaire *',
              hintText: 'Ex: Jean Dupont',
              prefixIcon: const Icon(Icons.badge_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Téléphone du bénéficiaire (optionnel)',
              hintText: 'Ex: 06 00 00 00 00',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildForOption(
    BuildContext context,
    Color primary, {
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _bookingFor == value;
    return GestureDetector(
      onTap: () => setState(() => _bookingFor = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primary : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? primary.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? primary : Colors.grey[500]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isSelected ? primary : const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primary : const Color(0xFFCBD5E1),
                  width: 2,
                ),
                color: isSelected ? primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTypeMotif(
    BuildContext context,
    Color primary,
    List<AppointmentKindModel> kinds,
    AsyncValue<List<AppointmentKindModel>> kindsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (kindsAsync.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (kinds.isNotEmpty) ...[
          const Text(
            'Type de consultation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          ...kinds.map((kind) {
            final isSelected = _selectedKind?.id == kind.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedKind = _selectedKind?.id == kind.id ? null : kind),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? primary.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? primary : const Color(0xFFE2E8F0),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      color: isSelected ? primary : Colors.grey[400],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kind.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? primary : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${kind.durationMins} min',
                            style: TextStyle(color: Colors.grey[500], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (kind.price != null)
                      Text(
                        '${kind.price!.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primary,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
        const Text(
          'Motif de la consultation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Décrivez brièvement le motif de votre visite (optionnel)...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            'Consultation de suivi',
            'Bilan de santé',
            'Douleur',
            'Fièvre',
            'Renouvellement ordonnance',
          ].map((s) {
            final isActive = _selectedChips.contains(s);
            return GestureDetector(
              onTap: () => setState(() {
                isActive ? _selectedChips.remove(s) : _selectedChips.add(s);
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? primary.withValues(alpha: 0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? primary : const Color(0xFFE2E8F0),
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  s,
                  style: TextStyle(
                    fontSize: 13,
                    color: isActive ? primary : const Color(0xFF475569),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStepConfirmation(
    BuildContext context,
    Color primary,
    List<AppointmentKindModel> kinds,
  ) {
    final dateStr = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(widget.slot.start);
    final timeStr = DateFormat('HH:mm').format(widget.slot.start);

    final rows = <Map<String, String>>[
      {
        'label': 'Patient',
        'value': _bookingFor == 'me'
            ? 'Moi-même'
            : _nameController.text.trim(),
      },
      {'label': 'Date', 'value': dateStr},
      {'label': 'Heure', 'value': timeStr},
      {
        'label': 'Type',
        'value': _selectedKind?.name ?? 'Consultation standard',
      },
    ];
    if (_notesController.text.trim().isNotEmpty) {
      rows.add({'label': 'Motif', 'value': _notesController.text.trim()});
    }
    if (_bookingFor == 'other' && _phoneController.text.trim().isNotEmpty) {
      rows.add({'label': 'Tél. bénéficiaire', 'value': _phoneController.text.trim()});
    }
    if (_selectedKind?.price != null) {
      rows.add({'label': 'Prix', 'value': '${_selectedKind!.price!.toStringAsFixed(0)} FCFA'});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Récapitulatif',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: rows.map((row) {
              final isLast = row == rows.last;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: !isLast
                      ? const Border(
                          bottom: BorderSide(color: Color(0xFFF1F5F9)),
                        )
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        row['label']!,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row['value']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, Color primary, List<AppointmentKindModel> kinds) {
    final isLastStep = _step == 2;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _goBack,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Retour'),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _goNext(kinds),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isLastStep ? 'Confirmer le rendez-vous' : 'Continuer'),
            ),
          ),
        ],
      ),
    );
  }
}
