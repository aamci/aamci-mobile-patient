import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';

class DocumentsRemoteDatasource {
  final ApiClient _apiClient;

  DocumentsRemoteDatasource(this._apiClient);

  Future<List<dynamic>> getDocuments() async {
    final response = await _apiClient.get(ApiEndpoints.medicalDocuments);
    return response.data as List;
  }
}
