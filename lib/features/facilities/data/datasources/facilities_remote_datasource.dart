import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';

class FacilitiesRemoteDatasource {
  final ApiClient _apiClient;
  FacilitiesRemoteDatasource(this._apiClient);

  Future<List<dynamic>> getFacilities() async {
    final response = await _apiClient.get(ApiEndpoints.facilities);
    return response.data as List;
  }

  Future<Map<String, dynamic>> getFacility(String id) async {
    final response = await _apiClient.get(ApiEndpoints.facilityById(id));
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getFacilityDoctors(String id) async {
    final response = await _apiClient.get(ApiEndpoints.facilityDoctors(id));
    // API returns { data: [...], meta: {...} }
    final body = response.data;
    if (body is Map && body['data'] is List) return body['data'] as List;
    if (body is List) return body;
    return [];
  }
}
