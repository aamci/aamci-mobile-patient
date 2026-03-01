import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/facilities_remote_datasource.dart';

final facilitiesRemoteProvider = Provider<FacilitiesRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FacilitiesRemoteDatasource(apiClient);
});

final facilitiesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final datasource = ref.watch(facilitiesRemoteProvider);
  final data = await datasource.getFacilities();
  return data.map((e) => e as Map<String, dynamic>).toList();
});

final facilityDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final datasource = ref.watch(facilitiesRemoteProvider);
  return datasource.getFacility(id);
});

final facilityDoctorsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, id) async {
  final datasource = ref.watch(facilitiesRemoteProvider);
  final data = await datasource.getFacilityDoctors(id);
  return data.map((e) => e as Map<String, dynamic>).toList();
});
