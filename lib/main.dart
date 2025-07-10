import 'package:flutter/material.dart';
import 'package:my_app/routes/routes.dart'; // Import the routes map

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: MyApp.scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'sweep',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      initialRoute: '/',
      routes: defineRoutes(),
    );
  }
}
