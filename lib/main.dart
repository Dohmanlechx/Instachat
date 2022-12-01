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
  String? _message = '';

  final _wholeMessage =
      'This is a test message. This should be written quite quickly. Every letter is going to Firebase and back. As you can see, an issue is how they do not notify when the value coming in is the same as the previous one, so we can not type duplicated letters. Whatever, a good start anyway. :-)';

  @override
  void initState() {
    super.initState();
    final ref = database.ref('chats/message');
    ref.onValue.listen((event) {
      setState(() {
        final next = event.snapshot.value as String?;
        _message = next == null ? _message : '$_message$next';
      });
    });
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$_message',
              style: Theme.of(context).textTheme.headline4,
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
