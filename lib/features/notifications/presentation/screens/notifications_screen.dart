import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationsRemoteProvider).markAllRead();
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadNotifCountProvider);
            },
            child: const Text('Tout lire'),
          ),
        ],
      ),
      body: notifsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erreur de chargement', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(notificationsProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (notifs) {
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Aucune notification', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationsProvider),
            child: ListView.builder(
              itemCount: notifs.length,
              itemBuilder: (context, index) {
                final notif = notifs[index];
                final isRead = notif['read'] == true;
                final title = notif['title'] as String? ?? 'Notification';
                final message = notif['message'] as String? ?? '';
                final type = notif['type'] as String?;

                final badge = _badgeForType(type);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isRead ? Colors.grey[200] : _colorForType(type).withValues(alpha: 0.15),
                    child: Icon(
                      _iconForType(type),
                      color: isRead ? Colors.grey[500] : _colorForType(type),
                      size: 20,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.w600),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: badge['color'] as Color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge['label'] as String,
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  tileColor: isRead ? null : _colorForType(type).withValues(alpha: 0.03),
                  onTap: () async {
                    if (!isRead) {
                      final id = notif['id']?.toString();
                      if (id != null) {
                        await ref.read(notificationsRemoteProvider).markRead(id);
                        ref.invalidate(notificationsProvider);
                        ref.invalidate(unreadNotifCountProvider);
                      }
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'APPOINTMENT_REMINDER':    return Icons.alarm;
      case 'APPOINTMENT_CONFIRMED':   return Icons.check_circle_outline;
      case 'APPOINTMENT_CANCELLED':   return Icons.cancel_outlined;
      case 'APPOINTMENT_RESCHEDULED': return Icons.update;
      case 'NEW_MESSAGE':             return Icons.chat_bubble_outline;
      case 'ALERT':                   return Icons.warning_amber_outlined;
      case 'PRESCRIPTION_EXPIRED':    return Icons.medication_outlined;
      default:                        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'NEW_MESSAGE':             return const Color(0xFF0D9488);
      case 'ALERT':                   return const Color(0xFFDC2626);
      case 'PRESCRIPTION_EXPIRED':    return const Color(0xFFF97316);
      default:                        return const Color(0xFF2563EB);
    }
  }

  Map<String, dynamic>? _badgeForType(String? type) {
    switch (type) {
      case 'NEW_MESSAGE':
        return {'label': 'Message', 'color': const Color(0xFF0D9488)};
      case 'ALERT':
        return {'label': 'Alerte', 'color': const Color(0xFFDC2626)};
      case 'PRESCRIPTION_EXPIRED':
        return {'label': 'Ordonnance', 'color': const Color(0xFFF97316)};
      default:
        if (type != null && type.startsWith('APPOINTMENT_')) {
          return {'label': 'RDV', 'color': const Color(0xFF2563EB)};
        }
        return null;
    }
  }
}
