import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/chat.dart';
import 'package:instachat/models/error_data.dart';
import 'package:instachat/providers/app_exceptions.dart';
import 'package:instachat/providers/chat.dart';
import 'package:instachat/providers/firebase.dart';
import 'package:instachat/providers/user.dart';
import 'package:instachat/repositories/chat_repository.dart';
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
  var _idCopiedToClipboard = false;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ..._chatBoxes(chat),
        const SizedBox(height: UI.p24),
        _leaveButton(),
      ],
    );
  }

  Widget _chatId(String id) {
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: id)).then(
          (_) {
            setState(() {
              _idCopiedToClipboard = true;
            });
            context.showSuccessSnackbar('Copied to clipboard!');
          },
        );
      },
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
                borderRadius: UI.radius,
                color: Colors.black.withOpacity(0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(UI.p8),
                child: Text(id,
                    style: const TextStyle(fontSize: 30).copyWith(
                      fontFamily: 'Sono',
                      color: Colors.orange,
                    )),
              ),
            ),
            const SizedBox(width: UI.p4),
            Icon(
              _idCopiedToClipboard
                  ? Icons.assignment_turned_in_rounded
                  : Icons.assignment_rounded,
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _leaveButton() {
    return GestureDetector(
      onTap: () async {
        final navigator = Navigator.of(context);
        await ref.read(chatRepositoryProvider).leave(widget.chatId);
        navigator.pop();
      },
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 200,
          height: 50,
          decoration: BoxDecoration(borderRadius: UI.radius, color: Colors.red),
          child: const Icon(Icons.phone_disabled_sharp),
        ),
      ),
    );
  }

  List<Widget> _chatBoxes(Chat? chat) {
    final chatId = chat?.id;
    final userId = ref.read(pUser).id;
    final friendUsers = chat?.friendUsers(userId) ?? [];
    final friends = friendUsers.isEmpty ? null : friendUsers;
    const pd = UI.p8;

    return [
      friends == null
          ? Expanded(
              child: Center(
                  child: chatId == null ? const SizedBox() : _chatId(chatId)),
            )
          : Expanded(
              flex: 5,
              child: Column(
                children: List.generate(friends.length, (i) {
                  final friend = friends[i];

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(pd),
                      child: SizedBox(
                        height: double.infinity,
                        child: FriendChatBox(
                          key: ValueKey(friend.id),
                          friend: friend,
                          chatId: widget.chatId,
                          isHost: widget.isAdmin,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
      const SizedBox(height: pd),
      Expanded(
        flex: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: pd),
          child: MyChatBox(
            user: ref.read(pUser),
            chatId: widget.chatId,
            isHost: widget.isAdmin,
          ),
        ),
      ),
    ];
  }
}
