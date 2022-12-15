import 'package:flutter/material.dart';

class ChatBox extends StatefulWidget {
  const ChatBox.me({super.key}) : isMe = true;
  const ChatBox.friend({super.key}) : isMe = false;

  final bool isMe;

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  late final ScrollController _scrollController;

  final String _message = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.isMe ? 'You' : 'Friend',
            style: Theme.of(context).textTheme.headline4),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.withOpacity(0.2),
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Text(
              _message,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ),
      ],
    );
  }
}
