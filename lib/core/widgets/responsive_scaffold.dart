import 'package:flutter/material.dart';

/// Contraint le contenu sur web (largeur max centrée) pour un rendu lisible.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.maxWidth = 900,
  });

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.sizeOf(context).width > 600;
    final child = body ?? const SizedBox.shrink();
    return Scaffold(
      appBar: appBar,
      body: isWeb
          ? Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            )
          : child,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Enveloppe le contenu avec une largeur max sur web (pour body déjà dans un Scaffold).
Widget responsiveBody(BuildContext context, Widget child, {double maxWidth = 900}) {
  final isWeb = MediaQuery.sizeOf(context).width > 600;
  if (!isWeb) return child;
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
