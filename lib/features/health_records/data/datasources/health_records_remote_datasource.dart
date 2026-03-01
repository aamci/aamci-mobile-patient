import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';

class HealthRecordsRemoteDatasource {
  final ApiClient _apiClient;

  HealthRecordsRemoteDatasource(this._apiClient);

  Future<Map<String, dynamic>> getHealthRecord() async {
    final response = await _apiClient.get(ApiEndpoints.healthRecords);
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getVitals() async {
    final response = await _apiClient.get(ApiEndpoints.vitals);
    return response.data as List;
  }

  Future<List<dynamic>> getVaccinations() async {
    final response = await _apiClient.get(ApiEndpoints.vaccinations);
    return response.data as List;
  }

  Future<List<dynamic>> getLabResults() async {
    final response = await _apiClient.get(ApiEndpoints.labResults);
    return response.data as List;
  }
}
