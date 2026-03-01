import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../doctors/data/models/doctor_model.dart';

class FavoritesRemoteDatasource {
  final ApiClient _apiClient;

  FavoritesRemoteDatasource(this._apiClient);

  Future<List<DoctorModel>> getFavorites() async {
    final response = await _apiClient.get(ApiEndpoints.favorites);
    final list = response.data as List;
    return list.map((e) => DoctorModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> toggleFavorite(String doctorId) async {
    await _apiClient.post(ApiEndpoints.toggleFavorite(doctorId));
  }

  Future<bool> isFavorite(String doctorId) async {
    final response = await _apiClient.get(ApiEndpoints.checkFavorite(doctorId));
    return response.data['isFavorite'] as bool? ?? false;
  }
}
