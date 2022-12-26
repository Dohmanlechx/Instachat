import 'package:flutter/material.dart';
import 'package:instachat/theme/ui.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({required this.body, super.key});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(padding: const EdgeInsets.all(UI.p16), child: body),
    );
  }
}
