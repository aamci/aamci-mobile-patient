import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/insurance_provider.dart';

class InsuranceScreen extends ConsumerStatefulWidget {
  const InsuranceScreen({super.key});

  @override
  ConsumerState<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends ConsumerState<InsuranceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _providerCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _mutualCtrl = TextEditingController();
  final _ssnCtrl = TextEditingController();

  bool _populated = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(insuranceProvider.notifier).load());
  }

  @override
  void dispose() {
    _providerCtrl.dispose();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _mutualCtrl.dispose();
    _ssnCtrl.dispose();
    super.dispose();
  }

  void _populateFields(InsuranceState state) {
    if (_populated || state.isLoading) return;
    _populated = true;
    final d = state.data;
    if (d == null) return;
    _providerCtrl.text = d.provider ?? '';
    _numberCtrl.text = d.number ?? '';
    _expiryCtrl.text = d.expiryDate ?? '';
    _mutualCtrl.text = d.mutualInsurance ?? '';
    _ssnCtrl.text = d.socialSecurityNumber ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'provider': _providerCtrl.text.trim(),
      'number': _numberCtrl.text.trim(),
      'expiryDate': _expiryCtrl.text.trim(),
      'mutualInsurance': _mutualCtrl.text.trim(),
      'socialSecurityNumber': _ssnCtrl.text.trim(),
    };
    final ok = await ref.read(insuranceProvider.notifier).save(data);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Informations enregistrées' : 'Erreur lors de l\'enregistrement'),
      backgroundColor: ok ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(insuranceProvider);
    _populateFields(state);

    return Scaffold(
      appBar: AppBar(title: const Text('Assurance maladie')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildField(
                      controller: _providerCtrl,
                      label: 'Organisme assureur',
                      hint: 'Ex : CNSS, MGEN...',
                      icon: Icons.business_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _numberCtrl,
                      label: 'Numéro de police / adhérent',
                      hint: 'Numéro de votre contrat',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _expiryCtrl,
                      label: "Date d'expiration",
                      hint: 'YYYY-MM-DD',
                      icon: Icons.calendar_month_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _mutualCtrl,
                      label: 'Mutuelle complémentaire',
                      hint: 'Nom de votre mutuelle',
                      icon: Icons.volunteer_activism_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _ssnCtrl,
                      label: 'Numéro de sécurité sociale',
                      hint: 'Votre numéro personnel',
                      icon: Icons.numbers_outlined,
                    ),
                    const SizedBox(height: 32),
                    if (state.error != null) ...[
                      Text(
                        state.error!,
                        style: const TextStyle(color: Color(0xFFEF4444)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ],
                    ElevatedButton(
                      onPressed: state.isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: state.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Enregistrer'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
