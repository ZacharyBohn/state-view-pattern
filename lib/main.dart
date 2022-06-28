import 'package:flutter/material.dart';

import 'pages/home.dart';

void main() {
  runApp(const MyApp());
  return;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}
