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
import 'package:instachat/util/extensions/context.dart';
import 'package:instachat/widgets/chat_box_friend.dart';
import 'package:instachat/widgets/chat_box_me.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    required this.chatId,
    required this.isHost,
    super.key,
  });

  final String chatId;
  final bool isHost;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  DatabaseReference get usersRef =>
      ref.read(pFirebase).ref('chats/${widget.chatId}/users');

  @override
  void initState() {
    super.initState();
    usersRef.onValue.listen((event) {
      ref.refresh(pChatById(widget.chatId));
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ErrorData?>(pAppExceptions, ((_, next) {
      final error = next;
      if (error != null) {
        context.showNegativeSnackBar(error);
      }
    }));

    return AppScaffold(
      body: ref.watch(pChatById(widget.chatId)).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            data: (chat) => _chatView(chat),
            error: ((error, stackTrace) {
              Future.microtask(() {
                ref.read(pAppExceptions.notifier).state =
                    ErrorData(error, stackTrace);
              });

              return Center(
                child: Text(
                  'Error!',
                  style: Theme.of(context).textTheme.headline2,
                ),
              );
            }),
          ),
    );
  }

  Widget _chatView(Chat chat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ..._viewForHost(
          chat.users.keys.where((e) => e != ref.read(pUserId)).toList(),
        ),
        const SizedBox(height: 30),
        GestureDetector(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: chat.id)).then(
              (_) => context.showPositiveSnackbar('Copied to clipboard!'),
            );
          },
          child: Center(
            child: Text(
              'Chat ID: ${chat.id}',
              style: const TextStyle(fontSize: 30),
            ),
          ),
        ),
        const SizedBox(height: 30),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Center(
            child: Text(
              'Leave',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _viewForHost(List<String> friendUserIds) {
    final friend = friendUserIds.isEmpty ? null : friendUserIds.first;

    return [
      friend == null
          ? const Spacer()
          : Expanded(
              child: FriendChatBox(
                friendUserId: friendUserIds.first,
                chatId: widget.chatId,
                isHost: widget.isHost,
              ),
            ),
      const SizedBox(height: UI.p16),
      Expanded(
        child: MyChatBox(
          userId: ref.read(pUserId),
          chatId: widget.chatId,
          isHost: widget.isHost,
        ),
      ),
    ];
  }
}
