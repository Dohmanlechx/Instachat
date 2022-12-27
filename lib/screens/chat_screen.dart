import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/chat.dart';
import 'package:instachat/models/error_data.dart';
import 'package:instachat/providers/app_exceptions.dart';
import 'package:instachat/providers/chat.dart';
import 'package:instachat/providers/firebase.dart';
import 'package:instachat/providers/user_id.dart';
import 'package:instachat/screens/app_scaffold.dart';
import 'package:instachat/theme/ui.dart';
import 'package:instachat/util/extensions/chat.dart';
import 'package:instachat/util/extensions/context.dart';
import 'package:instachat/widgets/chat_box_friend.dart';
import 'package:instachat/widgets/chat_box_me.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    required this.chatId,
    required this.isAdmin,
    super.key,
  });

  final String chatId;
  final bool isAdmin;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  DatabaseReference get usersRef =>
      ref.read(pFirebase).ref('chats/${widget.chatId}/users');

  @override
  void initState() {
    super.initState();
    usersRef.onValue.listen((_) => ref.refresh(pChatById(widget.chatId)));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ErrorData?>(pAppExceptions, ((_, next) {
      final error = next;
      if (error != null) {
        context.showErrorSnackbar(error);
      }
    }));

    return AppScaffold(
      body: ref.watch(pChatById(widget.chatId)).when(
            loading: () => _content(),
            data: (chat) => _content(chat),
            error: ((error, stackTrace) {
              Future.microtask(() {
                ref.read(pAppExceptions.notifier).state =
                    ErrorData(error, stackTrace);
                Navigator.of(context).pop();
              });

              return const SizedBox();
            }),
          ),
    );
  }

  Widget _content([Chat? chat]) {
    final chatId = chat?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ..._chatBoxes(chat),
        if (chatId != null) _chatId(chatId),
        _leaveButton(),
      ],
    );
  }

  Widget _chatId(String id) {
    return Padding(
      padding: const EdgeInsets.all(UI.p24),
      child: GestureDetector(
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: id)).then(
            (_) => context.showSuccessSnackbar('Copied to clipboard!'),
          );
        },
        child: Center(
          child: Text(
            'Chat ID: $id',
            style: const TextStyle(fontSize: 30),
          ),
        ),
      ),
    );
  }

  Widget _leaveButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          width: 100,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: Colors.red,
          ),
          child: const Icon(Icons.phone_disabled_sharp),
        ),
      ),
    );
  }

  List<Widget> _chatBoxes(Chat? chat) {
    final userId = ref.read(pUserId);
    final friendUserIds = chat?.friendUserIds(userId) ?? [];
    final friend = friendUserIds.isEmpty ? null : friendUserIds.first;

    return [
      friend == null
          ? Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(color: UI.secondary),
                    SizedBox(height: UI.p16),
                    Text(
                      'Waiting for someone to connect...',
                      style: TextStyle(color: UI.secondary),
                    )
                  ],
                ),
              ),
            )
          : Expanded(
              child: FriendChatBox(
                friendUserId: friend,
                chatId: widget.chatId,
                isHost: widget.isAdmin,
              ),
            ),
      const SizedBox(height: UI.p16),
      Expanded(
        child: MyChatBox(
          userId: ref.read(pUserId),
          chatId: widget.chatId,
          isHost: widget.isAdmin,
        ),
      ),
    ];
  }
}
