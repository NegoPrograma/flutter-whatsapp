import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp_mockup/Utils/RouteGenerator.dart';

class Messages extends StatefulWidget {
  String _contactName = "New User";
  String _profilePicURL = "";
  Messages(contact) {
    _contactName = contact["contactName"];
    _profilePicURL = contact["profilePicURL"];
  }
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  TextEditingController _emailController = TextEditingController();
  void _sendMessage() {}
  void _sendPhoto() {}

  Widget messageInputField;
  Widget messageListView;
  List<String> messageTest = [
    "EAE",
    "QUAL FOI",
    "BOA NOITE NEY JOGOU O QUE SABE",
    "vlw lek"
  ];
  void initState() {
    super.initState();

    messageListView = Expanded(
      child: ListView.builder(
          itemCount: messageTest.length,
          itemBuilder: (context, index) {
            Alignment align = Alignment.centerRight;
            Color messageColor = Colors.greenAccent;
            if (index.isEven) {
              align = Alignment.centerLeft;
              messageColor = Colors.white;
            }

            //deixando as imagens com 80% do espaço da tela
            double containerWidth = MediaQuery.of(context).size.width*80/100;

            
            return Align(
              alignment: align,
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Container(
                  width: containerWidth,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: messageColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    messageTest[index],
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            );
          }),
    );
    messageInputField = Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: TextField(
                  controller: _emailController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "Digite uma mensagem...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    prefixIcon: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () {
                        _sendPhoto();
                      },
                    ),
                  ),
                ),
              ),
            ),
            FloatingActionButton(
              backgroundColor: Color(0xff075E54),
              child: Icon(Icons.send, color: Colors.white),
              mini: true,
              onPressed: () {
                _sendMessage();
              },
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._contactName),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                messageListView,
                messageInputField,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
