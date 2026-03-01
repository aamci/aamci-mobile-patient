import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/messages_remote_datasource.dart';

final messagesRemoteProvider = Provider<MessagesRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MessagesRemoteDatasource(apiClient);
});

final conversationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final datasource = ref.watch(messagesRemoteProvider);
  final data = await datasource.getConversations();
  return data.map((e) => e as Map<String, dynamic>).toList();
});

final conversationMessagesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, conversationId) async {
  final datasource = ref.watch(messagesRemoteProvider);
  final data = await datasource.getMessages(conversationId);
  return data.map((e) => e as Map<String, dynamic>).toList();
});

final unreadMessageCountProvider = FutureProvider<int>((ref) async {
  final datasource = ref.watch(messagesRemoteProvider);
  return datasource.getUnreadCount();
});
