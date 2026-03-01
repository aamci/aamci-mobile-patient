import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';

class NotificationsRemoteDatasource {
  final ApiClient _apiClient;

  NotificationsRemoteDatasource(this._apiClient);

  Future<List<dynamic>> getNotifications({bool? unreadOnly}) async {
    final params = <String, dynamic>{};
    if (unreadOnly == true) params['unreadOnly'] = 'true';
    final response = await _apiClient.get(ApiEndpoints.notifications, queryParameters: params);
    return response.data as List;
  }

  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(ApiEndpoints.unreadCount);
    return (response.data as Map<String, dynamic>)['count'] as int? ?? 0;
  }

  Future<void> markRead(String id) async {
    await _apiClient.patch(ApiEndpoints.markRead(id));
  }

  Future<void> markAllRead() async {
    await _apiClient.patch(ApiEndpoints.markAllRead);
  }
}
