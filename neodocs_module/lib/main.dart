import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:neodocs_module/test/onboarding/test_onboarding.dart';
import 'package:bot_toast/bot_toast.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*try {
    await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }*/
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SDK Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in a Flutter IDE). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      builder: BotToastInit(),
      home: const TestOnBoarding(userId: "",),
    );
  }
}
