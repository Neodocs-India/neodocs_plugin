import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neodocs_module/test/onboarding/test_onboarding.dart';
import 'package:bot_toast/bot_toast.dart';

import 'constants/app_themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*try {
    await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }*/
  runApp(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return const MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SDK Demo',
      theme: AppThemes.newBrightTheme,
      builder: BotToastInit(),
      home: const TestOnBoarding(
        userId: "",
      ),
    );
  }
}
