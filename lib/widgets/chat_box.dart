import 'package:flutter/material.dart';
import 'package:instachat/theme/ui.dart';

class ChatBox extends StatelessWidget {
  const ChatBox({
    required this.child,
    required this.color,
    super.key,
  });

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: UI.radius,
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
