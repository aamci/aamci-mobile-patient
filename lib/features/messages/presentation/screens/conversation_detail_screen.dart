import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/storage/secure_storage.dart';
import '../providers/messages_provider.dart';

class ConversationDetailScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String participantName;
  final String participantId;

  const ConversationDetailScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    this.participantId = '',
  });

  @override
  ConsumerState<ConversationDetailScreen> createState() => _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends ConsumerState<ConversationDetailScreen> {
  final _messageController = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(messagesRemoteProvider).markConversationRead(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      final datasource = ref.read(messagesRemoteProvider);
      await datasource.sendMessage(conversationId: widget.conversationId, content: text);
      _messageController.clear();
      ref.invalidate(conversationMessagesProvider(widget.conversationId));
      ref.invalidate(conversationsProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur d\'envoi')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ActionsSheet(
        participantId: widget.participantId,
        participantName: widget.participantName,
        conversationId: widget.conversationId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(conversationMessagesProvider(widget.conversationId));
    final currentUserId = ref.watch(authProvider).user?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.participantName),
        actions: [
          if (widget.participantId.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showActionsMenu(context),
              tooltip: 'Signaler / Bloquer',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Erreur de chargement', style: TextStyle(color: Colors.grey[600])),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text('Aucun message', style: TextStyle(color: Colors.grey[500])),
                  );
                }
                final sorted = messages.reversed.toList();
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final msg = sorted[index];
                    final isMe = msg['senderId'] == currentUserId;
                    final content = msg['content'] as String? ?? '';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 16),
                          ),
                        ),
                        child: Text(
                          content,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Écrire un message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom sheet signalement / blocage ──────────────────────────────────────

class _ActionsSheet extends ConsumerStatefulWidget {
  final String participantId;
  final String participantName;
  final String conversationId;

  const _ActionsSheet({
    required this.participantId,
    required this.participantName,
    required this.conversationId,
  });

  @override
  ConsumerState<_ActionsSheet> createState() => _ActionsSheetState();
}

class _ActionsSheetState extends ConsumerState<_ActionsSheet> {
  String? _view; // null=menu, 'report', 'done'
  String _reason = '';
  String _details = '';
  bool _loading = false;
  String _doneMessage = '';

  static const _reasons = [
    ('INAPPROPRIATE_CONTENT',   'Contenu inapproprié'),
    ('HARASSMENT',              'Harcèlement ou comportement abusif'),
    ('SPAM',                    'Spam ou publicité non sollicitée'),
    ('FAKE_PROFILE',            'Faux profil ou usurpation d\'identité'),
    ('UNPROFESSIONAL_CONDUCT',  'Comportement non professionnel'),
    ('OTHER',                   'Autre'),
  ];

  Future<String?> _getToken() async {
    return SecureStorageService().getToken();
  }

  Future<void> _submitReport() async {
    if (_reason.isEmpty) return;
    setState(() => _loading = true);
    try {
      final token = await _getToken();
      final datasource = ref.read(messagesRemoteProvider);
      await datasource.report(
        targetId: widget.participantId,
        type: 'CONVERSATION',
        reason: _reason,
        details: _details.isNotEmpty ? _details : null,
        conversationId: widget.conversationId,
        token: token ?? '',
      );
      setState(() { _view = 'done'; _doneMessage = 'Signalement envoyé. Notre équipe va l\'examiner.'; });
    } catch (_) {
      setState(() { _view = 'done'; _doneMessage = 'Erreur lors du signalement. Réessayez plus tard.'; });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _block() async {
    setState(() => _loading = true);
    try {
      final token = await _getToken();
      final datasource = ref.read(messagesRemoteProvider);
      await datasource.blockUser(targetId: widget.participantId, token: token ?? '');
      setState(() { _view = 'done'; _doneMessage = 'Utilisateur bloqué. Vous ne recevrez plus de messages.'; });
    } catch (_) {
      setState(() { _view = 'done'; _doneMessage = 'Erreur lors du blocage.'; });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 36, height: 4, decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(2),
            )),
          ),
          const SizedBox(height: 16),

          if (_view == null) ...[
            Text(widget.participantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _tile(Icons.flag_outlined, 'Signaler', 'Signaler un comportement inapproprié',
              Colors.orange, () => setState(() => _view = 'report')),
            const SizedBox(height: 8),
            _tile(Icons.block, 'Bloquer', 'Ne plus recevoir de messages',
              Colors.red, _block, loading: _loading),
          ],

          if (_view == 'report') ...[
            const Text('Motif du signalement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _reason.isEmpty ? null : _reason,
              hint: const Text('Choisir un motif'),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: _reasons.map((r) => DropdownMenuItem(value: r.$1, child: Text(r.$2, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: (v) => setState(() => _reason = v ?? ''),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Détails (optionnel)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLines: 3,
              onChanged: (v) => setState(() => _details = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _view = null),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: (_reason.isEmpty || _loading) ? null : _submitReport,
                    child: _loading
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Envoyer'),
                  ),
                ),
              ],
            ),
          ],

          if (_view == 'done') ...[
            Center(
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
                  const SizedBox(height: 12),
                  Text(_doneMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, String subtitle, Color color, VoidCallback onTap, {bool loading = false}) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: loading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
