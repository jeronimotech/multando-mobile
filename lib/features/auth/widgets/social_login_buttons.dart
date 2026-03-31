import 'package:flutter/material.dart';
import '../../../core/colors.dart';

/// Social login buttons for Google and GitHub.
class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SocialButton(
          label: 'Continue with Google',
          icon: Icons.g_mobiledata,
          iconColor: MultandoColors.brandRed,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Google login coming soon')),
            );
          },
        ),
        const SizedBox(height: 12),
        _SocialButton(
          label: 'Continue with GitHub',
          icon: Icons.code,
          iconColor: MultandoColors.surface900,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('GitHub login coming soon')),
            );
          },
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor, size: 28),
        label: Text(
          label,
          style: const TextStyle(
            color: MultandoColors.surface700,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: MultandoColors.surface700,
          side: const BorderSide(color: MultandoColors.surface300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
