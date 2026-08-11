import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _resendLoading = false;
  bool _resendSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _resendSent = false; });
    ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  Future<void> _resendVerification() async {
    setState(() => _resendLoading = true);
    await ref.read(authProvider.notifier).resendVerification(_emailController.text.trim());
    if (mounted) setState(() { _resendLoading = false; _resendSent = true; });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Icon(Icons.local_hospital_rounded, size: 64, color: primary),
                const SizedBox(height: 16),
                Text(
                  'Health Platform',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous à votre compte',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Veuillez entrer votre email';
                    if (!v.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Veuillez entrer votre mot de passe';
                    if (v.length < 6) return 'Minimum 6 caractères';
                    return null;
                  },
                ),

                if (authState.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: authState.status == AuthStatus.emailVerificationRequired
                          ? Colors.orange.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: authState.status == AuthStatus.emailVerificationRequired
                            ? Colors.orange.shade200
                            : Colors.red.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          authState.error!,
                          style: TextStyle(
                            color: authState.status == AuthStatus.emailVerificationRequired
                                ? Colors.orange.shade800
                                : Colors.red.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (authState.status == AuthStatus.emailVerificationRequired) ...[
                          const SizedBox(height: 8),
                          _resendSent
                              ? const Text(
                                  'Email renvoyé ! Vérifiez votre boîte mail.',
                                  style: TextStyle(color: Colors.green, fontSize: 13),
                                  textAlign: TextAlign.center,
                                )
                              : TextButton(
                                  onPressed: _resendLoading ? null : _resendVerification,
                                  child: _resendLoading
                                      ? const SizedBox(height: 16, width: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Text('Renvoyer l\'email de vérification'),
                                ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: authState.status == AuthStatus.loading ? null : _submit,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
                  child: authState.status == AuthStatus.loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Se connecter'),
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Mot de passe oublié ?'),
                  ),
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text('Pas encore de compte ? S\'inscrire'),
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: () => context.push('/privacy'),
                  child: Text(
                    'Politique de confidentialité',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
