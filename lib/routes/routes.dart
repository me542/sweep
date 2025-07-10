import 'package:flutter/material.dart';
import 'package:my_app/screen/initialscreen.dart';
import '../screen/get.dart';

Map<String, WidgetBuilder> defineRoutes() {
  return {
    '/': (context) => InitialScreen(),
    '/get': (context) => GetStartedScreen(),
    // '/contact': (context) => ContactPage(),
  };
}
