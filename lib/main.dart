import 'package:flutter/material.dart';
import 'package:moviereviewsapp/login/forgotPassword.dart';
import 'package:moviereviewsapp/screens/loginScreen.dart';
import 'dart:io';
import './screens/home.dart';
import 'package:hive/hive.dart';
import 'models/movie.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Directory directory = await pathProvider.getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(MovieAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReviewsApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapShot) {
          if (userSnapShot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: Text('Loading....')));
          }

          if (userSnapShot.hasData) {
            return MyHomePage();
          }
          return LoginPage();
        },
      ),
      routes: {
        MyHomePage.id: (context) => MyHomePage(),
        ForgotPassword.id: (context) => ForgotPassword(),
        // AddEditMovies.id: (context) => AddEditMovies(),
      },
    );
  }
}
