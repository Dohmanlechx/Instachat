import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:instachat/firebase_options.dart';

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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

  late final ScrollController _scrollController;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    final ref = database.ref('chats');

    final ref2 = database.ref('chats/message');

    ref2.onValue.listen((event) {
      setState(() {
        var next = event.snapshot.value as String?;
        _message = next ?? '';
      });
    });

    _scrollController = ScrollController();

    _controller = TextEditingController()
      ..addListener(() async {
        var value = _controller.text;
        await ref.set({'message': value});
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Text(
                  _message,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                toolbarOptions: const ToolbarOptions(selectAll: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
