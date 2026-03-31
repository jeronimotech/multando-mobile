import 'package:flutter/material.dart';
import '../../core/colors.dart';

/// Consistent app bar used across Multando screens.
class MultandoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MultandoAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showLogo = false,
    this.backgroundColor,
    this.elevation,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLogo;
  final Color? backgroundColor;
  final double? elevation;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: showLogo
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/multando_logo.png',
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ],
            )
          : Text(title),
      actions: actions,
      leading: leading,
      backgroundColor: backgroundColor,
      elevation: elevation,
    );
  }
}
