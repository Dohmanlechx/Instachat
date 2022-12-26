import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/providers/firebase.dart';
import 'package:instachat/theme/ui.dart';

class FriendChatBox extends ConsumerStatefulWidget {
  const FriendChatBox(this.chatId, {required this.isHost, super.key});

  final String chatId;
  final bool isHost;

  @override
  ConsumerState<FriendChatBox> createState() => _FriendChatBoxState();
}

class _FriendChatBoxState extends ConsumerState<FriendChatBox> {
  late final ScrollController _scrollController;

  String _message = '';

  DatabaseReference get messageFromHostRef =>
      ref.read(pFirebase).ref('chats/${widget.chatId}/messageFromHost');

  DatabaseReference get messageFromGuestRef =>
      ref.read(pFirebase).ref('chats/${widget.chatId}/messageFromGuest');

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    DatabaseReference databaseRef;

    if (widget.isHost) {
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
        borderRadius: UI.radius,
        color: UI.secondary.withOpacity(0.2),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(UI.p16),
          child: Text(
            _message,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
      ),
    );
  }
}
