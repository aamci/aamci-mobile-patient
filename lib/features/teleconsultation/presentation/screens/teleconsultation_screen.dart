import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/api_endpoints.dart';

class TeleconsultationScreen extends ConsumerStatefulWidget {
  final String appointmentId;
  final String? doctorName;

  const TeleconsultationScreen({
    super.key,
    required this.appointmentId,
    this.doctorName,
  });

  @override
  ConsumerState<TeleconsultationScreen> createState() =>
      _TeleconsultationScreenState();
}

class _TeleconsultationScreenState
    extends ConsumerState<TeleconsultationScreen> {
  bool _cameraOn = true;
  bool _micOn = true;
  bool _isJoining = false;

  Future<void> _joinCall() async {
    setState(() => _isJoining = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        ApiEndpoints.startVideo(widget.appointmentId),
      );
      final data = response.data as Map<String, dynamic>;
      final videoUrl = data['url'] as String?;

      if (videoUrl != null && videoUrl.isNotEmpty) {
        final uri = Uri.parse(videoUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Impossible d\'ouvrir le lien vidéo')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lien vidéo non disponible')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur lors du démarrage de la vidéo')),
        );
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Retour',
        ),
        title: Text(
          widget.doctorName != null
              ? 'Dr. ${widget.doctorName}'
              : 'Téléconsultation',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Camera preview placeholder
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _cameraOn ? Icons.videocam : Icons.videocam_off,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _cameraOn
                            ? 'Votre caméra sera activée'
                            : 'Caméra désactivée',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ControlButton(
                    icon: _micOn ? Icons.mic : Icons.mic_off,
                    isActive: _micOn,
                    onPressed: () => setState(() => _micOn = !_micOn),
                    label: _micOn ? 'Micro' : 'Muet',
                  ),
                  const SizedBox(width: 24),
                  _ControlButton(
                    icon: _cameraOn ? Icons.videocam : Icons.videocam_off,
                    isActive: _cameraOn,
                    onPressed: () => setState(() => _cameraOn = !_cameraOn),
                    label: _cameraOn ? 'Caméra' : 'Éteinte',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Join button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isJoining ? null : _joinCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: _isJoining
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.video_call),
                  label: Text(
                      _isJoining ? 'Connexion...' : 'Rejoindre la consultation'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;
  final String label;

  const _ControlButton({
    required this.icon,
    required this.isActive,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: isActive
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.red.withValues(alpha: 0.3),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                icon,
                color: isActive ? Colors.white : Colors.red[300],
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
