import 'package:flutter/material.dart';

import 'package:testflask/pages/home.dart';


MaterialApp app = MaterialApp(
  theme: ThemeData(
    primaryColor: Colors.cyan,
  ),
  initialRoute: "/map",
  routes: {
    "/map": (context) =>const Home(),
  },
);

void main() {
  runApp(app);
}