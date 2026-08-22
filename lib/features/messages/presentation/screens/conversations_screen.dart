import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/messages_provider.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erreur de chargement', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(conversationsProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Aucune conversation', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(conversationsProvider),
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conv = conversations[index];
                final other = conv['otherParticipant'] as Map<String, dynamic>? ?? {};
                final name = other['fullName'] as String? ?? 'Utilisateur';
                final specialty = (other['doctorProfile'] as Map<String, dynamic>?)?['specialty'] as String?;
                final lastMessage = conv['lastMessage'] as String? ?? '';
                final unread = conv['unreadCount'] as int? ?? 0;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      name.substring(0, 1).toUpperCase(),
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal),
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (specialty != null)
                        Text(specialty, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: unread > 0 ? Colors.black87 : Colors.grey[600],
                          fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    final convId = conv['id']?.toString();
                    if (convId != null) {
                      context.push('/conversation/$convId', extra: {
                        'name': name,
                        'conversationId': convId,
                        'participantId': other['id']?.toString() ?? '',
                      });
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
}
