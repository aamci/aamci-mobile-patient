import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';

class MessagesRemoteDatasource {
  final ApiClient _apiClient;

  MessagesRemoteDatasource(this._apiClient);

  Future<List<dynamic>> getConversations() async {
    final response = await _apiClient.get(ApiEndpoints.conversations);
    return (response.data as List?) ?? [];
  }

  Future<List<dynamic>> getMessages(String conversationId, {int take = 50, String? cursor}) async {
    final params = <String, dynamic>{'take': take};
    if (cursor != null) params['cursor'] = cursor;
    final response = await _apiClient.get(
      ApiEndpoints.conversationMessages(conversationId),
      queryParameters: params,
    );
    return (response.data as List?) ?? [];
  }

  Future<Map<String, dynamic>> sendMessage({
    String? conversationId,
    String? recipientId,
    required String content,
  }) async {
    final response = await _apiClient.post(ApiEndpoints.sendMessage, data: {
      if (conversationId != null) 'conversationId': conversationId,
      if (recipientId != null) 'recipientId': recipientId,
      'content': content,
      'type': 'TEXT',
    });
    return (response.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> markConversationRead(String conversationId) async {
    await _apiClient.post(ApiEndpoints.markConversationRead(conversationId));
  }

  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(ApiEndpoints.unreadMessageCount);
    return (response.data as Map<String, dynamic>)['count'] as int? ?? 0;
  }
}
