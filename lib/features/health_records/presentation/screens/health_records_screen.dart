import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            _buildList(vitals, Icons.monitor_heart, 'Aucun signe vital enregistré'),
            _buildList(vaccinations, Icons.vaccines, 'Aucun vaccin enregistré'),
            _buildList(labResults, Icons.science, 'Aucun résultat d\'analyse'),
          ],
        ),
      ),
    );
  }

  Widget _buildList(AsyncValue<List<dynamic>> asyncData, IconData emptyIcon, String emptyMsg) {
    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Erreur de chargement', style: TextStyle(color: Colors.grey[600])),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(emptyIcon, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(emptyMsg, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index] as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(item['name'] ?? item['type'] ?? 'Entrée ${index + 1}'),
                subtitle: Text(item['date'] ?? item['createdAt'] ?? ''),
                trailing: item['value'] != null
                    ? SizedBox(
                        width: 80,
                        child: Text(
                          '${item['value']}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
