import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/consents_provider.dart';

class _ConsentMeta {
  final String type;
  final String label;
  final String description;
  final bool locked;
  const _ConsentMeta({required this.type, required this.label, required this.description, this.locked = false});
}

const _consentMeta = [
  _ConsentMeta(
    type: 'CARE',
    label: 'Consentement aux soins',
    description: 'Obligatoire pour utiliser la plateforme de santé.',
    locked: true,
  ),
  _ConsentMeta(
    type: 'DATA_SHARING',
    label: 'Partage de données médicales',
    description: 'Autoriser les professionnels de santé à accéder à votre dossier.',
  ),
  _ConsentMeta(
    type: 'TELECONSULTATION',
    label: 'Téléconsultation',
    description: 'Participer à des consultations vidéo avec votre médecin.',
  ),
  _ConsentMeta(
    type: 'EMAIL_COMMUNICATION',
    label: 'Communications électroniques',
    description: 'Recevoir des rappels de rendez-vous et informations par email / SMS.',
  ),
  _ConsentMeta(
    type: 'RESEARCH',
    label: 'Recherche clinique',
    description: 'Contribuer anonymement à des études médicales.',
  ),
];

class ConsentsScreen extends ConsumerStatefulWidget {
  const ConsentsScreen({super.key});

  @override
  ConsumerState<ConsentsScreen> createState() => _ConsentsScreenState();
}

class _ConsentsScreenState extends ConsumerState<ConsentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(consentsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(consentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes consentements')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(consentsProvider.notifier).load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.25)),
                    ),
                    child: const Text(
                      'Conformément à la Loi 025/2023 (Gabon), vous pouvez gérer vos consentements à tout moment. Le consentement aux soins est obligatoire.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF0D9488)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(state.error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                    ),
                  Card(
                    child: Column(
                      children: _consentMeta.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final meta = entry.value;
                        final record = state.consents.firstWhere(
                          (c) => c.type == meta.type,
                          orElse: () => ConsentRecord(type: meta.type, granted: meta.locked),
                        );
                        final isUpdating = state.updatingType == meta.type;

                        return Column(
                          children: [
                            if (idx > 0) const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              meta.label,
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                            ),
                                            if (meta.locked) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text('Obligatoire', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(meta.description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                        if (!record.granted && record.revokedAt != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Révoqué le ${DateFormat('d MMM yyyy', 'fr_FR').format(record.revokedAt!)}',
                                            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  isUpdating
                                      ? const SizedBox(
                                          width: 36,
                                          height: 20,
                                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                        )
                                      : Switch(
                                          value: record.granted,
                                          onChanged: meta.locked
                                              ? null
                                              : (v) => _confirmToggle(context, meta.label, meta.type, v),
                                          activeColor: const Color(0xFF0D9488),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _confirmToggle(BuildContext context, String label, String type, bool newValue) async {
    if (newValue) {
      ref.read(consentsProvider.notifier).update(type, true);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Révoquer le consentement'),
        content: Text('Voulez-vous révoquer votre consentement à "$label" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Révoquer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(consentsProvider.notifier).update(type, false);
    }
  }
}
