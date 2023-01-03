import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/user.dart';
import 'package:instachat/providers/firebase.dart';
import 'package:instachat/theme/ui.dart';
import 'package:instachat/widgets/chat_box.dart';
import 'package:instachat/widgets/chat_user_name.dart';

class FriendChatBox extends ConsumerStatefulWidget {
  const FriendChatBox({
    required this.friend,
    required this.chatId,
    required this.isHost,
    super.key,
  });

  final User friend;
  final String chatId;
  final bool isHost;

  @override
  ConsumerState<FriendChatBox> createState() => _FriendChatBoxState();
}

class _FriendChatBoxState extends ConsumerState<FriendChatBox> {
  late final ScrollController _scrollController;

  String _message = '';

  DatabaseReference get messageFromHostRef => ref
      .read(pFirebase)
      .ref('chats/${widget.chatId}/users/${widget.friend.id}/message');

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    DatabaseReference databaseRef;

    databaseRef = messageFromHostRef;

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
    return ChatBox(
      color: UI.chatbox,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(UI.p16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChatUserName(widget.friend.name),
              Text(
                _message,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
