import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:instachat/firebase_options.dart';
import 'package:instachat/models/chat.dart';
import 'package:instachat/theme/theme.dart';
import 'package:instachat/util/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

final database = FirebaseDatabase.instance;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const MyHomePage(title: Constants.appName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ref = database.ref('chats');

  String _message = '';
  bool host = true;

  late final ScrollController _scrollController;
  late final TextEditingController _controller;

  var chat = Chat(id: '1337');

  @override
  void initState() {
    super.initState();

    final ref = database.ref('chats');

    final refMessageFromHost = database.ref('chats/messageFromHost');
    final refMessageFromGuest = database.ref('chats/messageFromGuest');

    refMessageFromHost.onValue.listen((event) {
      if (host) return;

      setState(() {
        var next = event.snapshot.value as String?;
        _message = next ?? '';
      });
    });

    refMessageFromGuest.onValue.listen((event) {
      if (!host) return;

      setState(() {
        var next = event.snapshot.value as String?;
        _message = next ?? '';
      });
    });

    _scrollController = ScrollController();

    _controller = TextEditingController()
      ..addListener(() async {
        var value = _controller.text;

        if (host) {
          chat = chat.copyWith(messageFromHost: value);
        } else {
          chat = chat.copyWith(messageFromGuest: value);
        }

        print(chat);

        await ref.update(chat.toJson());
        //await ref.update({key: value});
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
      Text('Your friend', style: ICTheme.typefaces.bold30),
      Expanded(
        child: Container(
          width: double.infinity,
          color: Colors.grey.withOpacity(0.2),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Text(
              _message,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ),
      ),
      Text('You', style: ICTheme.typefaces.bold30),
      Expanded(
        child: Container(
          width: double.infinity,
          color: Colors.blueGrey.withOpacity(0.2),
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            toolbarOptions: const ToolbarOptions(selectAll: false),
            decoration: null,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ..._viewForHost(),
            TextButton(
              onPressed: () {
                setState(() {
                  host = !host;
                });
              },
              child: Center(
                child: Text(
                  host ? 'Host' : 'Guest',
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
