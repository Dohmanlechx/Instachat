import 'package:flutter/material.dart';
import 'package:instachat/theme/ui.dart';

class ChatUserName extends StatelessWidget {
  const ChatUserName(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(name, style: UI.bold20.copyWith(color: UI.primary));
  }
}
