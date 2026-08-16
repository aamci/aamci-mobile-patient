import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/health_records_provider.dart';

class HealthRecordsScreen extends ConsumerWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vitals = ref.watch(vitalsProvider);
    final vaccinations = ref.watch(vaccinationsProvider);
    final labResults = ref.watch(labResultsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dossier médical'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Signes vitaux'),
              Tab(text: 'Vaccins'),
              Tab(text: 'Analyses'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _VitalsTab(vitals: vitals),
            _buildList(vaccinations, Icons.vaccines, 'Aucun vaccin enregistré',
                titleKey: 'vaccineName', dateKey: 'administeredAt'),
            _buildList(labResults, Icons.science, 'Aucun résultat d\'analyse',
                titleKey: 'testName', dateKey: 'resultDate', valueKey: 'result'),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    AsyncValue<List<dynamic>> asyncData,
    IconData emptyIcon,
    String emptyMsg, {
    String titleKey = 'name',
    String dateKey = 'createdAt',
    String? valueKey,
  }) {
    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: e.toString()),
      data: (items) {
        if (items.isEmpty) return _EmptyState(icon: emptyIcon, message: emptyMsg);
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index] as Map<String, dynamic>;
            final dateRaw = item[dateKey]?.toString();
            final dateStr = dateRaw != null
                ? DateFormat('d MMM yyyy', 'fr_FR')
                    .format(DateTime.tryParse(dateRaw) ?? DateTime.now())
                : '';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(item[titleKey]?.toString() ?? item['type']?.toString() ?? 'Entrée ${index + 1}'),
                subtitle: Text(dateStr),
                trailing: valueKey != null && item[valueKey] != null
                    ? Text('${item[valueKey]}',
                        style: const TextStyle(fontWeight: FontWeight.w600))
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}

class _VitalsTab extends StatelessWidget {
  final AsyncValue<Map<String, dynamic>> vitals;
  const _VitalsTab({required this.vitals});

  @override
  Widget build(BuildContext context) {
    return vitals.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: e.toString()),
      data: (data) {
        final measurements = data['recentMeasurements'] as List? ?? [];
        final hasBasic = data['bloodType'] != null ||
            data['heightCm'] != null ||
            data['weightKg'] != null;
        final isEmpty = !hasBasic && measurements.isEmpty;

        if (isEmpty) return const _EmptyState(icon: Icons.monitor_heart, message: 'Aucun signe vital enregistré');

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (hasBasic) ...[
              const _SectionHeader('Informations de base'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (data['bloodType'] != null)
                    _VitalChip(
                      icon: Icons.bloodtype,
                      label: 'Groupe sanguin',
                      value: '${data['bloodType']}${data['rhesus'] ?? ''}',
                      color: const Color(0xFFEF4444),
                    ),
                  if (data['heightCm'] != null)
                    _VitalChip(
                      icon: Icons.height,
                      label: 'Taille',
                      value: '${data['heightCm']} cm',
                      color: const Color(0xFF2563EB),
                    ),
                  if (data['weightKg'] != null)
                    _VitalChip(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Poids',
                      value: '${data['weightKg']} kg',
                      color: const Color(0xFF10B981),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            if (measurements.isNotEmpty) ...[
              const _SectionHeader('Mesures récentes'),
              const SizedBox(height: 8),
              ...measurements.map((m) {
                final mMap = m as Map<String, dynamic>;
                final dateRaw = mMap['measuredAt']?.toString();
                final dateStr = dateRaw != null
                    ? DateFormat('d MMM yyyy HH:mm', 'fr_FR')
                        .format(DateTime.tryParse(dateRaw) ?? DateTime.now())
                    : '';
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.show_chart, color: Color(0xFF0D9488)),
                    title: Text(_measurementLabel(mMap['type']?.toString())),
                    subtitle: Text(dateStr),
                    trailing: mMap['value'] != null
                        ? Text(
                            '${mMap['value']}${mMap['unit'] != null ? ' ${mMap['unit']}' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          )
                        : null,
                  ),
                );
              }),
            ],
          ],
        );
      },
    );
  }

  String _measurementLabel(String? type) {
    switch (type) {
      case 'BLOOD_PRESSURE': return 'Tension artérielle';
      case 'HEART_RATE': return 'Fréquence cardiaque';
      case 'TEMPERATURE': return 'Température';
      case 'OXYGEN_SATURATION': return 'Saturation en oxygène';
      case 'BLOOD_GLUCOSE': return 'Glycémie';
      case 'WEIGHT': return 'Poids';
      case 'HEIGHT': return 'Taille';
      default: return type ?? 'Mesure';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
            letterSpacing: 0.5));
  }
}

class _VitalChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _VitalChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('Erreur de chargement', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, style: TextStyle(color: Colors.grey[400], fontSize: 12),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
