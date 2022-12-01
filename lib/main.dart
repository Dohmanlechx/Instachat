import 'dart:math';

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
  final int _counter = 0;

  String _prevLetter = '';
  String _message = '';

  final sameAsBefore = '[same_as_before]';
  final sameAsBefore1 = '[same_as_before1]';
  String whichLatest = '';

  final _wholeMessage =
      'This is a test message. This should be written quite quickly. Every letter is going to Firebase and back. As you can see, an issue is how they do not notify when the value coming in is the same as the previous one, so we can not type duplicated letters. Whatever, a good start anyway. :-)';

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    final ref = database.ref('chats');

    final ref2 = database.ref('chats/message');

    ref2.onValue.listen((event) {
      setState(() {
        var next = event.snapshot.value as String?;

        if (next == sameAsBefore || next == sameAsBefore1) {
          next = _prevLetter;
        }

        _message = next == null ? _message : '$_message$next';
      });
    });

    _controller = TextEditingController()
      ..addListener(() async {
        final length = _controller.text.length;
        if (_controller.text.isEmpty) return;
        var value = _controller.text[max(0, length - 1)];

        if (value == _prevLetter) {
          value = sameAsBefore;

          if (whichLatest == sameAsBefore) {
            value = sameAsBefore1;
          } else if (whichLatest == sameAsBefore1) {
            value = sameAsBefore;
          }

          whichLatest = value;
        } else {
          _prevLetter = value;
        }

        await ref.set({'message': value});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _incrementCounter() async {
    for (var i = 0; i < _wholeMessage.length; i++) {
      await ref.set({'message': _wholeMessage[i]});
    }

    await ref.remove();
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
              child: Text(
                _message,
                style: Theme.of(context).textTheme.headline4,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
