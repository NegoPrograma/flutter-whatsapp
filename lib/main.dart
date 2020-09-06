import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp_mockup/Login.dart';
import 'Utils/RouteGenerator.dart';

void main() async {
  runApp(
    MaterialApp(
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff075E54),
        accentColor: Color(0xff25d366),
      ),
      initialRoute: "/",
      onGenerateRoute: RouteGenerator.generateRoute,
    ),
  );
}
