import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groupie/homey.dart';
import 'firebase_options.dart';
import 'oss_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
            primaryColor: CupertinoColors.activeBlue,
            appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white, foregroundColor: Colors.black)),
        home: const Usahili(),
      ));
    } else {
      runApp(MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
              primaryColor: CupertinoColors.activeBlue,
              appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black)),
          home: const HomeMain()));
    }
  });
}
