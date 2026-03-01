import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AuthRemoteDatasource(this._apiClient, this._storage);

  Future<UserModel> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    final token = response.data['token'] as String;
    await _storage.saveToken(token);
    return await getCurrentUser();
  }

  Future<UserModel> register(String email, String password, String fullName) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'role': 'PATIENT',
      },
    );
    final data = response.data as Map<String, dynamic>;
    // API requires email verification before the account is usable
    if (data['requiresVerification'] == true) {
      throw Exception('EMAIL_VERIFICATION_REQUIRED');
    }
    final token = data['token'] as String;
    await _storage.saveToken(token);
    return await getCurrentUser();
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data);
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (_) {}
    await _storage.clearAll();
  }
}
