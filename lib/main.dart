import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/firebase_options.dart';
import 'package:instachat/providers/chat.dart';
import 'package:instachat/theme/ui.dart';
import 'package:instachat/util/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

final database = FirebaseDatabase.instance;

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
  String _message = '';
  bool host = true;

  late final ScrollController _scrollController;
  late final TextEditingController _controller;

  DatabaseReference get databaseRef {
    final chat = ref.read(chatProvider);
    return database.ref('chats/${chat?.id}');
  }

  DatabaseReference get messageFromHostRef {
    final chat = ref.read(chatProvider);
    return database.ref('chats/hardcodedId/messageFromHost');
  }

  DatabaseReference get messageFromGuestRef {
    final chat = ref.read(chatProvider);
    return database.ref('chats/hardcodedId/messageFromGuest');
  }

  @override
  void initState() {
    super.initState();

    messageFromHostRef.onValue.listen((event) {
      if (host) return;

      setState(() {
        var next = event.snapshot.value as String?;
        _message = next ?? '';
        ref.read(chatProvider.notifier).updateHostMessage(_message);
      });

      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    messageFromGuestRef.onValue.listen((event) {
      if (!host) return;

      setState(() {
        var next = event.snapshot.value as String?;
        _message = next ?? '';
        ref.read(chatProvider.notifier).updateGuestMessage(_message);
      });
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    _scrollController = ScrollController();

    _controller = TextEditingController()
      ..addListener(() async {
        var value = _controller.text;

        if (host) {
          ref.read(chatProvider.notifier).updateHostMessage(value);
        } else {
          ref.read(chatProvider.notifier).updateGuestMessage(value);
        }

        final chat = ref.read(chatProvider);

        await databaseRef.update(chat!.toJson());
        if (!_scrollController.hasClients) return;
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _viewForHost() {
    return [
      Text('Your friend', style: Theme.of(context).textTheme.headline4),
      Expanded(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.withOpacity(0.2),
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Text(
              _message,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: UI.p16),
        child: Text('You', style: Theme.of(context).textTheme.headline4),
      ),
      Expanded(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blueGrey.withOpacity(0.2),
          ),
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            style: Theme.of(context).textTheme.headline5,
            decoration: null,
          ),
        ),
      ),
    ];
  }

  Widget _start() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            host = true;
            ref.read(chatProvider.notifier).init();
          },
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.teal.withOpacity(0.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(UI.p16),
                child: Text('Start Chat',
                    style: Theme.of(context).textTheme.headline3),
              ),
            ),
          ),
        ),
        const SizedBox(height: UI.p16),
        GestureDetector(
          onTap: () async {
            host = false;
            ref
                .read(chatProvider.notifier)
                .join('hardcodedId')
                .catchError((error) => print(error));
          },
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.teal.withOpacity(0.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(UI.p16),
                child: Text('Join chat',
                    style: Theme.of(context).textTheme.headline3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chat() {
    final chat = ref.watch(chatProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ..._viewForHost(),
        const SizedBox(height: 30),
        chat == null
            ? const SizedBox()
            : Center(
                child: Text(
                  'Chat ID: ${chat.id}',
                  style: const TextStyle(fontSize: 30),
                ),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);

    ref.watch(pvrChats).whenData((value) => null);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(UI.p16),
        child: chat == null ? _start() : _chat(),
      ),
    );
  }
}
