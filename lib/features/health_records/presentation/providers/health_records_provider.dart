import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/health_records_remote_datasource.dart';

final healthRecordsRemoteProvider = Provider<HealthRecordsRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HealthRecordsRemoteDatasource(apiClient);
});

final healthRecordProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final datasource = ref.watch(healthRecordsRemoteProvider);
  return datasource.getHealthRecord();
});

final vitalsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final datasource = ref.watch(healthRecordsRemoteProvider);
  return datasource.getVitals();
});

final vaccinationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final datasource = ref.watch(healthRecordsRemoteProvider);
  return datasource.getVaccinations();
});

final labResultsProvider = FutureProvider<List<dynamic>>((ref) async {
  final datasource = ref.watch(healthRecordsRemoteProvider);
  return datasource.getLabResults();
});
