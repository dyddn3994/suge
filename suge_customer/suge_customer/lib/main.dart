import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:suge_customer/validator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 상태바 배경색을 투명으로 설정
      statusBarIconBrightness: Brightness.dark,
    ));

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF414ffd, {
          50: Color(0xFF414ffd),
          100: Color(0xFF414ffd),
          200: Color(0xFF414ffd),
          300: Color(0xFF414ffd),
          400: Color(0xFF414ffd),
          500: Color(0xFF414ffd),
          600: Color(0xFF414ffd),
          700: Color(0xFF414ffd),
          800: Color(0xFF414ffd),
          900: Color(0xFF414ffd),
        }),
      ),
      home: Validator(),
    );
  }
}
