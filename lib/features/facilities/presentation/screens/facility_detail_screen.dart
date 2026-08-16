import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/facilities_provider.dart';
import '../../../doctors/data/models/doctor_model.dart';

class FacilityDetailScreen extends ConsumerWidget {
  final String facilityId;
  final Map<String, dynamic>? facilityData;

  const FacilityDetailScreen({
    super.key,
    required this.facilityId,
    this.facilityData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facilityAsync = facilityData != null
        ? AsyncValue.data(facilityData!)
        : ref.watch(facilityDetailProvider(facilityId));
    final doctorsAsync = ref.watch(facilityDoctorsProvider(facilityId));

    return Scaffold(
      appBar: AppBar(
        title: Text(facilityData?['name'] as String? ?? 'Établissement'),
      ),
      body: facilityAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(facilityDetailProvider(facilityId)),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (facility) {
          final name = facility['name'] as String? ?? 'Établissement';
          final address = facility['address'] as String? ?? '';
          final city = facility['city'] as String? ?? '';
          final phone = facility['phone'] as String? ?? '';
          final type = facility['type'] as String? ?? '';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Facility info section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1),
                            child: Icon(
                              Icons.local_hospital,
                              size: 28,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                if (type.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      type,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (address.isNotEmpty || city.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 20, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                [address, city]
                                    .where((s) => s.isNotEmpty)
                                    .join(', '),
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined,
                                size: 20, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              phone,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Doctors section
              Text(
                'Médecins',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              doctorsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text(
                          'Erreur de chargement des médecins',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(
                              facilityDoctorsProvider(facilityId)),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (doctors) {
                  // Filter out deleted/inactive accounts
                  final activeDoctors = doctors.where((d) {
                    final user = d['user'] as Map<String, dynamic>?;
                    final name = user?['fullName'] as String? ?? '';
                    return name.isNotEmpty && !name.toLowerCase().contains('supprim');
                  }).toList();

                  if (activeDoctors.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.person_off_outlined,
                                size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 8),
                            Text(
                              'Aucun médecin dans cet établissement',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Card(
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: activeDoctors.asMap().entries.map((entry) {
                        final index = entry.key;
                        final doctor = entry.value;
                        final user = doctor['user'] as Map<String, dynamic>?;
                        final fullName = user?['fullName'] as String? ?? 'Médecin';
                        final specialty = doctor['specialty'] as String? ?? '';

                        final doctorModel = DoctorModel(
                          id: user?['id'] as String? ?? doctor['id'] as String,
                          fullName: fullName,
                          email: user?['email'] as String? ?? '',
                          avatarUrl: user?['avatarUrl'] as String?,
                          doctorProfile: DoctorProfile(
                            id: doctor['id'] as String,
                            specialty: specialty,
                          ),
                        );

                        return Column(
                          children: [
                            if (index > 0) const Divider(height: 1),
                            ListTile(
                              onTap: () => context.push(
                                '/doctor/${doctorModel.id}',
                                extra: doctorModel,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                                child: Text(
                                  fullName.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text('Dr. $fullName'),
                              subtitle: specialty.isNotEmpty ? Text(specialty) : null,
                              trailing: const Icon(Icons.chevron_right, size: 18),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
