import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/notifications_remote_datasource.dart';

final notificationsRemoteProvider = Provider<NotificationsRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationsRemoteDatasource(apiClient);
});

final notificationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final datasource = ref.watch(notificationsRemoteProvider);
  final data = await datasource.getNotifications();
  return data.map((e) => e as Map<String, dynamic>).toList();
});

final unreadNotifCountProvider = FutureProvider<int>((ref) async {
  final datasource = ref.watch(notificationsRemoteProvider);
  return datasource.getUnreadCount();
});
