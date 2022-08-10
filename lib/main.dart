import 'package:flutter/material.dart';
import 'package:testflask/pages/home.dart';
// import 'package:testflask/pages/geojson.dart';
// import 'package:testflask/pages/syncfusionTest.dart';
// import 'package:testflask/pages/flutter_map_slow.dart';

MaterialApp app = MaterialApp(
  theme: ThemeData(
    primaryColor: Colors.cyan,
  ),
  home:  const Home(),
);

void main() {
  runApp(app);
}