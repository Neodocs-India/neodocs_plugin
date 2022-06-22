import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:neodocs_package/neodocs_package.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      builder: BotToastInit(), //important for toast in the library
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final Map<String,String> map = {
    "userId": "userId",
    "firstName": "firstName",
    "lastName": "lastName",
    "gender": "gender",
    "dateOfBirth": "${DateTime.now().millisecondsSinceEpoch}",
    "apiKey": "NCqeTHkBa2QTdwM3H2UXO4H9iQbb4N1eXNKbzVi0"
  };

  void startTest() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TestOnBoarding(user:map)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              onPressed: ()=>startTest(),
              child: const Text("Start Test"),
            )
          ],
        ),
      ),
    );
  }
}
