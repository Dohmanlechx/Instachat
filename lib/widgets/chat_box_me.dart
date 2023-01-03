import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/user.dart';
import 'package:instachat/repositories/chat_repository.dart';
import 'package:instachat/theme/ui.dart';
import 'package:instachat/widgets/chat_box.dart';
import 'package:instachat/widgets/chat_user_name.dart';

class MyChatBox extends ConsumerStatefulWidget {
  const MyChatBox({
    required this.user,
    required this.chatId,
    required this.isHost,
    super.key,
  });

  final User user;
  final String chatId;
  final bool isHost;

  @override
  ConsumerState<MyChatBox> createState() => _MyChatBoxState();
}

class _MyChatBoxState extends ConsumerState<MyChatBox> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController()
      ..addListener(() async {
        var value = _controller.text;

        await ref.read(chatRepositoryProvider).updateMessage(
              widget.chatId,
              widget.user.id,
              message: value,
            );
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChatBox(
      color: UI.myChatbox,
      child: Padding(
        padding: const EdgeInsets.all(UI.p16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChatUserName(widget.user.name),
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: Theme.of(context).textTheme.headline5,
                decoration: const InputDecoration(
                  hintText: 'Write something...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
