import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/error_data.dart';
import 'package:instachat/providers/app_exceptions.dart';
import 'package:instachat/providers/chat.dart';
import 'package:instachat/repositories/chat_repository.dart';
import 'package:instachat/screens/app_scaffold.dart';
import 'package:instachat/screens/chat_screen.dart';
import 'package:instachat/theme/ui.dart';
import 'package:instachat/util/extensions/context.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  ConsumerState<HomeScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<HomeScreen> {
  bool host = true;
  String? _chatId;

  late final ScrollController _scrollController;
  late final TextEditingController _controller;
  late final TextEditingController _idController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _controller = TextEditingController()
      ..addListener(() async {
        var value = _controller.text;

        if (host) {
          await ref
              .read(chatRepositoryProvider)
              .updateHostMessage(_chatId!, message: value);
        } else {
          await ref
              .read(chatRepositoryProvider)
              .updateGuestMessage(_chatId!, message: value);
        }

        if (!_scrollController.hasClients) return;
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });

    _idController = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    _idController.dispose();
    super.dispose();
  }

  Widget _start() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            host = true;
            final navigator = Navigator.of(context);
            final id = await ref.read(chatRepositoryProvider).create();
            await navigator.push(
              PageRouteBuilder(
                pageBuilder: ((_, __, ___) =>
                    ChatScreen(chatId: id, isHost: host)),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          child: Center(
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.indigoAccent,
              ),
              child: Padding(
                padding: const EdgeInsets.all(UI.p16),
                child: Center(
                    child: Text('Start',
                        style: Theme.of(context).textTheme.headline3)),
              ),
            ),
          ),
        ),
        const SizedBox(height: UI.p16),
        GestureDetector(
          onTap: () async {
            host = false;
            await showDialog(
              context: context,
              builder: ((context) {
                return AlertDialog(
                  title: const Text('TextField in Dialog'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (value) {},
                        controller: _idController,
                        decoration: const InputDecoration(
                          hintText: "write the id here",
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          setState(() {
                            ref.invalidate(pChatById);
                            _chatId = _idController.text;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          color: Colors.green,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: Text('OK')),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }),
            );
          },
          child: Center(
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.indigoAccent,
              ),
              child: Padding(
                padding: const EdgeInsets.all(UI.p16),
                child: Center(
                    child: Text('Join',
                        style: Theme.of(context).textTheme.headline3)),
              ),
            ),
          ),
        ),
      ],
    );
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
      body: _start(),
    );
  }
}
