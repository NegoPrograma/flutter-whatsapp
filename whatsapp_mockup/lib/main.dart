import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  runApp(MaterialApp(home: Scaffold(appBar: AppBar(backgroundColor: Colors.black,),)));
  FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: "email2@gmail.com", password: "email@gmail.com");
  FirebaseUser user = await FirebaseAuth.instance.currentUser();
  print(user);
}
