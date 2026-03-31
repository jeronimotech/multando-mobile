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
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: MultandoColors.brandRed,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
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
