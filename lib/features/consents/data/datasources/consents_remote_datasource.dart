import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';

class ConsentRecord {
  final String type;
  final bool granted;
  final DateTime? grantedAt;
  final DateTime? revokedAt;

  ConsentRecord({required this.type, required this.granted, this.grantedAt, this.revokedAt});

  factory ConsentRecord.fromJson(Map<String, dynamic> j) => ConsentRecord(
        type: j['type'] as String,
        granted: j['granted'] as bool? ?? false,
        grantedAt: j['grantedAt'] != null ? DateTime.tryParse(j['grantedAt'] as String) : null,
        revokedAt: j['revokedAt'] != null ? DateTime.tryParse(j['revokedAt'] as String) : null,
      );
}

class ConsentsRemoteDatasource {
  final ApiClient _apiClient;
  ConsentsRemoteDatasource(this._apiClient);

  Future<List<ConsentRecord>> getConsents(String userId) async {
    final res = await _apiClient.get(ApiEndpoints.patientConsents(userId));
    final list = res.data as List? ?? [];
    return list.map((e) => ConsentRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> updateConsent(String userId, String type, bool granted) async {
    await _apiClient.post(
      ApiEndpoints.patientConsents(userId),
      data: {'type': type, 'granted': granted},
    );
  }
}
