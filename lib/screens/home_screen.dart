import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/error_data.dart';
import 'package:instachat/providers/app_exceptions.dart';
import 'package:instachat/repositories/chat_repository.dart';
import 'package:instachat/screens/app_scaffold.dart';
import 'package:instachat/screens/chat_screen.dart';
import 'package:instachat/theme/ui.dart';
import 'package:instachat/util/constants.dart';
import 'package:instachat/util/extensions/context.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  ConsumerState<HomeScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<HomeScreen> {
  late final ScrollController _scrollController;
  late final TextEditingController _idController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _idController = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Widget _start() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(Constants.appName,
            style: UI.stereofidelic.copyWith(fontSize: 100, color: UI.accent)),
        const SizedBox(height: UI.p24),
        GestureDetector(
          onTap: () async {
            final navigator = Navigator.of(context);
            final id = await ref.read(chatRepositoryProvider).create();
            await navigator.push(
              PageRouteBuilder(
                pageBuilder: ((_, __, ___) =>
                    ChatScreen(chatId: id, isAdmin: true)),
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
                color: UI.chatbox,
              ),
              child: Padding(
                padding: const EdgeInsets.all(UI.p16),
                child: Center(
                  child: Text(
                    'Start',
                    style: UI.stereofidelic.copyWith(
                      fontSize: 50,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: UI.p16),
        GestureDetector(
          onTap: () async {
            await showDialog(
              context: context,
              builder: ((context) {
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (value) {},
                        controller: _idController,
                        decoration: const InputDecoration(
                          hintText: "Paste the ID here!",
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: UI.p16),
                      GestureDetector(
                        onTap: () async {
                          Navigator.of(context).pop();
                          final navigator = Navigator.of(context);
                          await ref
                              .read(chatRepositoryProvider)
                              .join(_idController.text);

                          await navigator.push(
                            PageRouteBuilder(
                              pageBuilder: ((_, __, ___) => ChatScreen(
                                    chatId: _idController.text,
                                    isAdmin: false,
                                  )),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: UI.radius,
                            color: Colors.green,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: Text('Join')),
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
                color: UI.myChatbox,
              ),
              child: Padding(
                padding: const EdgeInsets.all(UI.p16),
                child: Center(
                  child: Text(
                    'Join',
                    style: UI.stereofidelic.copyWith(
                      fontSize: 50,
                      color: Colors.black,
                    ),
                  ),
                ),
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
        context.showErrorSnackbar(error);
      }
    }));

    return AppScaffold(
      body: _start(),
    );
  }
}
