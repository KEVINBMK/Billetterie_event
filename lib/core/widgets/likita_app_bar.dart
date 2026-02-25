import 'package:flutter/material.dart';
import '../theme/likita_theme.dart';

/// AppBar avec le branding LikitaEvent : "Likita" en bleu, "Event" en rouge.
class LikitaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LikitaAppBar({
    super.key,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  final String? title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: LikitaColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: title != null
          ? Text(title!)
          : const _LikitaLogo(),
      actions: actions,
    );
  }
}

class _LikitaLogo extends StatelessWidget {
  const _LikitaLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Likita',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          'Event',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: LikitaColors.accentRed,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
