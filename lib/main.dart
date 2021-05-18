import 'package:flutter/material.dart';
import 'package:todoapp/theme/theme.dart';
import 'package:todoapp/screens/home.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
    title: "Todo List",
    themeMode: ThemeMode.system,
    theme: lightTheme(),
    darkTheme: darkTheme(),
  ));
}
