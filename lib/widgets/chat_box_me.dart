import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/repositories/chat_repository.dart';
import 'package:instachat/theme/ui.dart';

class MyChatBox extends ConsumerStatefulWidget {
  const MyChatBox(this.chatId, {required this.isHost, super.key});

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

        if (widget.isHost) {
          await ref
              .read(chatRepositoryProvider)
              .updateHostMessage(widget.chatId, message: value);
        } else {
          await ref
              .read(chatRepositoryProvider)
              .updateGuestMessage(widget.chatId, message: value);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: UI.radius,
        color: UI.myChatbox,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(UI.p16),
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
    );
  }
}
