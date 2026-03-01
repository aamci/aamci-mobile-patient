import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = authState.user?.fullName ?? 'Patient';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Platform'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, $userName',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comment allez-vous aujourd\'hui ?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.search, color: Color(0xFF0D9488)),
                title: const Text('Trouver un médecin'),
                subtitle: const Text('Recherchez par spécialité ou nom'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/doctors'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFF0D9488)),
                title: const Text('Mes rendez-vous'),
                subtitle: const Text('Consultez vos prochains RDV'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/appointments'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.folder_outlined, color: Color(0xFF0D9488)),
                title: const Text('Dossier médical'),
                subtitle: const Text('Accédez à votre historique'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/health-records'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.favorite_outline, color: Color(0xFF0D9488)),
                title: const Text('Mes favoris'),
                subtitle: const Text('Médecins enregistrés'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/favorites'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.description_outlined, color: Color(0xFF0D9488)),
                title: const Text('Documents médicaux'),
                subtitle: const Text('Ordonnances, résultats...'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/documents'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
