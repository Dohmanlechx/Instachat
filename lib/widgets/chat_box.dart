import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChatBox extends StatefulWidget {
  const ChatBox.me(this.chatId, {required this.iAmHost, super.key})
      : isMe = true;
  const ChatBox.friend(this.chatId, {required this.iAmHost, super.key})
      : isMe = false;

  final String chatId;
  final bool isMe;
  final bool iAmHost;

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  late final ScrollController _scrollController;

  String _message = '';

  DatabaseReference get messageFromHostRef {
    return FirebaseDatabase.instance
        .ref('chats/${widget.chatId}/messageFromHost');
  }

  DatabaseReference get messageFromGuestRef {
    return FirebaseDatabase.instance
        .ref('chats/${widget.chatId}/messageFromGuest');
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    DatabaseReference databaseRef;

    if (widget.iAmHost) {
      databaseRef = messageFromGuestRef;
    } else {
      databaseRef = messageFromHostRef;
    }

    databaseRef.onValue.listen((event) {
      setState(() {
        var next = event.snapshot.value as String?;
        _message = next ?? '';
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: widget.isMe
            ? Colors.blueGrey.withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Text(
          _message,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
    );
  }
}
