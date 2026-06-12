import 'package:flutter/material.dart';
import 'package:pocket_memory_pet/core/theme/app_theme.dart';

class RetroScreenScaffold extends StatelessWidget {
  const RetroScreenScaffold({
    required this.child,
    this.title,
    this.actions,
    super.key,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null ? null : AppBar(title: Text(title!), actions: actions),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.cloudWhite, Color(0xFFFFE4D6), Color(0xFFEAD8C4)],
          ),
        ),
        child: SafeArea(
          child: child,
        ),
      ),
    );
  }
}
