import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/firebase_options.dart';
import 'package:instachat/models/chat.dart';
import 'package:instachat/models/error_data.dart';
import 'package:instachat/providers/app_exceptions.dart';
import 'package:instachat/providers/chat.dart';
import 'package:instachat/repositories/chat_repository.dart';
import 'package:instachat/theme/ui.dart';
import 'package:instachat/util/constants.dart';
import 'package:instachat/widgets/chat_box_friend.dart';
import 'package:instachat/widgets/chat_box_me.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      theme: UI.theme,
      home: const SafeArea(
        child: MyHomePage(title: Constants.appName),
      ),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
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

  List<Widget> _viewForHost() {
    return [
      Text('Your friend', style: Theme.of(context).textTheme.headline4),
      Expanded(
        child: FriendChatBox(_chatId!, isHost: host),
      ),
      Padding(
        padding: const EdgeInsets.only(top: UI.p16),
        child: Text('You', style: Theme.of(context).textTheme.headline4),
      ),
      Expanded(
        child: MyChatBox(_chatId!, isHost: host),
      ),
    ];
  }

  Widget _start() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            host = true;
            final id = await ref.read(chatRepositoryProvider).create();
            setState(() {
              //_chatId = "flour-economically-skin";
              ref.invalidate(pChatById);
              _chatId = id;
            });
          },
          child: Center(
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.teal.withOpacity(0.2),
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
                color: Colors.teal.withOpacity(0.2),
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

  Widget _chat(Chat chat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ..._viewForHost(),
        const SizedBox(height: 30),
        GestureDetector(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: chat.id)).then((_) {
              _showSnackBar('Copied to clipboard!');
            });
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
          onTap: () => setState(() {
            _chatId = null;
          }),
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(UI.p8),
                  child: Text(
                    message,
                    style: UI.regular20,
                    maxLines: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _showErrorSnackBar(ErrorData errorData) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(UI.p8),
                  child: Text(
                    kDebugMode
                        ? errorData.exception.toString()
                        : 'Something went wrong!',
                    style: UI.regular20,
                    maxLines: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ErrorData?>(pAppExceptions, ((_, next) {
      final error = next;
      if (error != null) {
        _showErrorSnackBar(error);
      }
    }));

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(UI.p16),
        child: ref.watch(pChatById(_chatId)).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              data: (chat) {
                return chat == null ? _start() : _chat(chat);
              },
              error: ((error, stackTrace) {
                return _start();
              }),
            ),
      ),
    );
  }
}
