import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hopin/infoHandler/app_info.dart';
import 'package:hopin/screens/forgotpassword.dart';
import 'package:hopin/screens/login_screen.dart';

import 'package:hopin/screens/main_page.dart';
import 'package:hopin/screens/register_screen.dart';
import 'package:hopin/splashScreen/splash_screen.dart';
import 'package:hopin/themeProvider/theme_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBpk3HxyarhOoJH8EFh3AZYo_iTYLF09s8",
      appId: "1:280856582634:android:326a126d8bfe347f057a93",
      messagingSenderId: "280856582634",
      projectId: "hopin-260db",
      authDomain: "hopin-260db.firebaseapp.com",
      databaseURL: "https://hopin-260db-default-rtdb.firebaseio.com",
      storageBucket: "hopin-260db.appspot.com",
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.r
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'Flutter Demo',
        themeMode: ThemeMode.system,
        theme: MyTheme.lightTheme,
        darkTheme: MyTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: MainScreen(),
      ),
    );
  }
}
