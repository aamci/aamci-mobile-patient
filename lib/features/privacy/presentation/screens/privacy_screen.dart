import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _sections = [
    _Section(
      title: '1. Responsable du traitement',
      content:
          'Ibogha Health, société de droit gabonais, est responsable du traitement de vos données personnelles collectées via cette application.',
    ),
    _Section(
      title: '2. Données collectées',
      content:
          'Nous collectons : données d\'identification (nom, email, téléphone), données de santé (rendez-vous, dossiers médicaux, prescriptions, notes médicales), données de facturation et de paiement, et données de connexion (logs, adresses IP).',
    ),
    _Section(
      title: '3. Finalités du traitement',
      content:
          'Vos données sont traitées pour : la gestion de votre compte patient, la prise et le suivi de rendez-vous médicaux, la communication sécurisée avec les professionnels de santé, la facturation et le remboursement, et l\'amélioration de nos services.',
    ),
    _Section(
      title: '4. Données de santé (données sensibles)',
      content:
          'Les données de santé bénéficient d\'une protection renforcée. Elles sont chiffrées (AES-256-GCM) au repos et en transit. Leur traitement est strictement limité aux professionnels de santé qui vous suivent.',
    ),
    _Section(
      title: '5. Durée de conservation',
      content:
          'Vos données de profil sont conservées pendant la durée de votre inscription. Les données médicales sont conservées 10 ans conformément aux obligations légales gabonaises. Les données de connexion sont conservées 12 mois.',
    ),
    _Section(
      title: '6. Vos droits',
      content:
          'Conformément à la Loi 025/2023, vous disposez des droits suivants :\n• Droit d\'accès : obtenir une copie de vos données\n• Droit de rectification : corriger vos données via votre profil\n• Droit à l\'effacement : demander la suppression de votre compte\n• Droit à la portabilité : exporter vos données\n• Droit d\'opposition et de limitation',
    ),
    _Section(
      title: '7. Sécurité',
      content:
          'Mesures mises en œuvre : chiffrement AES-256-GCM des données sensibles, hachage Argon2 des mots de passe, authentification à deux facteurs (2FA), connexions HTTPS/TLS, journalisation des accès.',
    ),
    _Section(
      title: '8. Partage des données',
      content:
          'Vos données ne sont jamais vendues. Elles sont partagées uniquement avec les professionnels de santé que vous consultez, nos prestataires techniques (hébergement sécurisé), et les autorités compétentes sur réquisition légale.',
    ),
    _Section(
      title: '9. Contact',
      content:
          'Pour exercer vos droits ou pour toute question, contactez-nous via le formulaire de support de l\'application ou par email à : privacy@ibogha.ga',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Politique de confidentialité')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Base légale', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0D9488))),
                const SizedBox(height: 4),
                const Text(
                  'Loi N° 025/2023 du 9 juillet 2023 modifiant la loi de 2011 sur la protection des données personnelles — République Gabonaise.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF0D9488)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Autorité de contrôle : APDPVP.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF0D9488)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dernière mise à jour : mai 2026',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ..._sections.map((s) => _SectionCard(section: s)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Section {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});
}

class _SectionCard extends StatelessWidget {
  final _Section section;
  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Text(section.content, style: const TextStyle(fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
