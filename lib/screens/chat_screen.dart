import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/error_data.dart';
import 'package:instachat/providers/app_exceptions.dart';
import 'package:instachat/providers/chat.dart';
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
            data: (chat) => _chatView(),
            error: ((error, stackTrace) {
              ref.read(pAppExceptions.notifier).state =
                  ErrorData(error, stackTrace);
              return _chatView();
            }),
          ),
    );
  }

  Widget _chatView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ..._viewForHost(),
        const SizedBox(height: 30),
        GestureDetector(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: widget.chatId)).then(
              (_) => context.showPositiveSnackbar('Copied to clipboard'),
            );
          },
          child: Center(
            child: Text(
              'Chat ID: ${widget.chatId}',
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

  List<Widget> _viewForHost() {
    return [
      Expanded(
        child: FriendChatBox(widget.chatId, isHost: widget.isHost),
      ),
      const SizedBox(height: UI.p16),
      Expanded(
        child: MyChatBox(widget.chatId, isHost: widget.isHost),
      ),
    ];
  }
}
