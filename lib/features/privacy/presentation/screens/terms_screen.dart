import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const _sections = [
    _Section(
      title: '1. Présentation du service',
      content:
          'Ibogha est une plateforme numérique de santé permettant aux patients de rechercher des professionnels de santé, de prendre des rendez-vous en ligne, d\'effectuer des téléconsultations, de consulter leurs dossiers médicaux et de communiquer de façon sécurisée avec leurs praticiens.',
    ),
    _Section(
      title: '2. Accès au service',
      content:
          'L\'accès à Ibogha est réservé aux personnes physiques majeures (18 ans et plus). Les mineurs peuvent être pris en charge via le compte d\'un représentant légal.\n\nL\'inscription est gratuite pour les patients. Vous êtes seul responsable de la confidentialité de vos identifiants de connexion.',
    ),
    _Section(
      title: '3. Obligations de l\'utilisateur',
      content:
          'En utilisant Ibogha, vous vous engagez à :\n• Fournir des informations exactes et à jour\n• Ne pas usurper l\'identité d\'une autre personne ou d\'un professionnel de santé\n• Ne pas utiliser le service à des fins illicites ou frauduleuses\n• Ne pas tenter d\'accéder aux données d\'autres utilisateurs\n• Respecter les professionnels de santé et les autres utilisateurs',
    ),
    _Section(
      title: '4. Prise de rendez-vous',
      content:
          'La réservation d\'un rendez-vous constitue un engagement ferme entre le patient et le professionnel de santé. Ibogha agit en tant qu\'intermédiaire technique.\n\nAnnulation : en cas d\'empêchement, le rendez-vous doit être annulé au moins 24 heures à l\'avance via l\'application.',
    ),
    _Section(
      title: '5. Téléconsultation',
      content:
          'La téléconsultation vidéo permet une consultation médicale à distance. Vous devez disposer d\'une connexion stable, d\'un appareil avec caméra et microphone, et vous trouver dans un lieu garantissant la confidentialité.\n\n⚠️ En cas d\'urgence médicale, appelez le 15 (SAMU) ou rendez-vous aux urgences.',
    ),
    _Section(
      title: '6. Informations médicales',
      content:
          'Les contenus informatifs disponibles sur Ibogha ont un caractère purement informatif et ne se substituent en aucun cas à un avis médical professionnel. Ibogha ne peut être tenu responsable des décisions médicales prises sur la seule base des informations disponibles.',
    ),
    _Section(
      title: '7. Paiements',
      content:
          'Les paiements sont traités par des prestataires sécurisés (Stripe, Airtel Money). Les données bancaires ne sont pas stockées sur nos serveurs.\n\nRemboursements : en cas d\'annulation dans les délais, le remboursement est effectué sous 5 à 10 jours ouvrés.',
    ),
    _Section(
      title: '8. Propriété intellectuelle',
      content:
          'L\'ensemble du contenu de la plateforme Ibogha (textes, graphiques, logos, interface, code source) est protégé par le droit de la propriété intellectuelle. Toute reproduction sans autorisation écrite est strictement interdite.',
    ),
    _Section(
      title: '9. Limitation de responsabilité',
      content:
          'Ibogha ne peut être tenu responsable :\n• Des actes ou omissions des professionnels de santé inscrits\n• Des interruptions liées à des maintenances ou pannes techniques\n• Des dommages indirects résultant de l\'utilisation du service',
    ),
    _Section(
      title: '10. Données personnelles',
      content:
          'Le traitement de vos données est régi par notre Politique de confidentialité, accessible depuis ce menu. Vos données médicales sont chiffrées avec AES-256-GCM et ne sont jamais revendues.\n\nContact données : privacy@ibogha241.ga',
    ),
    _Section(
      title: '11. Résiliation',
      content:
          'Vous pouvez supprimer votre compte à tout moment depuis les paramètres. Ibogha se réserve le droit de résilier un compte en cas de violation des présentes CGU.',
    ),
    _Section(
      title: '12. Modifications et contact',
      content:
          'Ibogha peut modifier ces conditions et vous informera 30 jours avant toute modification substantielle.\n\nContact : support@ibogha241.ga\nDonnées : privacy@ibogha241.ga',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditions générales d\'utilisation')),
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
                const Text('Acceptation des conditions', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0D9488))),
                const SizedBox(height: 4),
                const Text(
                  'En utilisant Ibogha, vous acceptez les présentes conditions générales dans leur intégralité.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF0D9488)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.1 — août 2026',
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
