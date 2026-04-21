import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/colors.dart';
import '../providers/auth_provider.dart';

/// Social login buttons.
class SocialLoginButtons extends ConsumerStatefulWidget {
  const SocialLoginButtons({super.key});

  @override
  ConsumerState<SocialLoginButtons> createState() =>
      _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends ConsumerState<SocialLoginButtons> {
  bool _isGoogleLoading = false;

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);

    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // Web client ID — required for serverAuthCode / ID token that
        // the backend can verify. Android/iOS client IDs are resolved
        // automatically from GoogleService-Info.plist / build config.
        serverClientId:
            '449342482335-apj5humkt26ouif20gkd0ak6qoc5sktv.apps.googleusercontent.com',
      );
      final account = await googleSignIn.signIn();

      if (account == null) {
        // User cancelled the sign-in flow.
        return;
      }

      final authentication = await account.authentication;
      final idToken = authentication.idToken;

      if (idToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to get Google ID token. Please try again.'),
            ),
          );
        }
        return;
      }

      await ref.read(authProvider.notifier).socialLogin(
            provider: 'google',
            idToken: idToken,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SocialButton(
      label: 'Continue with Google',
      icon: Icons.g_mobiledata,
      iconColor: MultandoColors.brandRed,
      isLoading: _isGoogleLoading,
      onPressed: _handleGoogleSignIn,
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: iconColor, size: 28),
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
