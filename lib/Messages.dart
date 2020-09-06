import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp_mockup/Utils/RouteGenerator.dart';

class Messages extends StatefulWidget {
  String _contactName = "New User";
  String _profilePicURL = "";
  String _userId = "";
  String _contactId = "";

  Messages(contact) {
    _contactName = contact["contactName"];
    _profilePicURL = contact["profilePicURL"];
    _userId = contact['userId'];
    _contactId = contact['contactId'];
    print(_contactId);
  }
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  TextEditingController _messageController = TextEditingController();
  StreamBuilder messageStream;
  Firestore db = Firestore.instance;
  void _sendMessage() {
    String message = _messageController.text;

    if (message.isNotEmpty) {
      Map<String, dynamic> messageJSON = {
        "userId": widget._userId,
        'message': message,
        "imageURL": "",
        "type": "text"
      };

      _storeMessage(widget._userId, widget._contactId, messageJSON);
      _storeMessage(widget._contactId,widget._userId, messageJSON);
    }
  }

  void _storeMessage(
      String senderId, String receiverId, Map<String, dynamic> message) async {
    /**
     * Estrutura:
     * 
     * messages->id de quem mandou -> uma mesma pessoa pode ter mandado
     * para varias outras, então não adianta só colocar quem recebeu depois,
     * façamos então uma segunda collection:
     * 
     * messages->id de quem mandou -> collection representando quem recebeu
     * ->conjunto de mensagens.
     */
    await db
        .collection("messages")
        .document(senderId)
        .collection(receiverId)
        .add(message);

    _messageController.clear();
  }

  void _sendPhoto() {}

  Widget messageInputField;
  List<String> messageTest = [
    "EAE",
    "QUAL FOI",
    "BOA NOITE NEY JOGOU O QUE SABE",
    "vlw lek"
  ];
  Stream _recoverMessages() {
    return db
        .collection("messages")
        .document(widget._userId)
        .collection(widget._contactId).orderBy()
        .snapshots();
  }

  void initState() {
    super.initState();

    messageStream = StreamBuilder(
        stream: _recoverMessages(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              Center(
                child: Column(
                  children: [
                    Text("Carregando mensagens"),
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              QuerySnapshot qs = snapshot.data;
              if (snapshot.hasError) {
                return Expanded(
                  child: Text("Erro ao carregar dados"),
                );
              } else {
                return Expanded(
                  child: ListView.builder(
                      itemCount: qs.documents.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> message = qs.documents[index].data;
                        Alignment align = Alignment.centerLeft;
                        Color messageColor = Colors.white;
                        if (message['userId'] == widget._userId) {
                          align = Alignment.centerRight;
                          messageColor = Colors.greenAccent;
                        }

                        //deixando as imagens com 80% do espaço da tela
                        double containerWidth =
                            MediaQuery.of(context).size.width * 0.8;

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
                                message['message'],
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        );
                      }),
                );
              }
              break;
          }
          return Container();
        });
   
    messageInputField = Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: TextField(
                  controller: _messageController,
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
        title: Row(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 10, 8),
            child: CircleAvatar(
              maxRadius: 20,
              backgroundImage: NetworkImage(widget._profilePicURL),
            ),
          ),
          Text(widget._contactName),
        ]),
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
                messageStream,
                messageInputField,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
