import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp_mockup/Utils/RouteGenerator.dart';

class Conversations extends StatefulWidget {
  Map<String, dynamic> user;

  Conversations(this.user);
  @override
  _ConversationsState createState() => _ConversationsState();
}

class _ConversationsState extends State<Conversations> {
  final _chatController = StreamController<QuerySnapshot>.broadcast();

  @override
  void initState() {
    super.initState();

    _setUserValues();
  }

  void _setUserValues() async {
    
    String userId = "";
    await FirebaseAuth.instance.currentUser().then((value) async {
      userId = value.uid;
    }).catchError((onError) => print(onError));
    Timer(Duration(seconds: 1), () {
      _getConversations(userId);
    });
  }

  Stream<QuerySnapshot> _getConversations(String id) {
    Firestore db = Firestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("conversations")
        .document(id)
        .collection("last_conversation")
        .snapshots();
    stream.listen((data) {
      _chatController.add(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _chatController.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: [
                    Text(
                      "Carregando conversas",
                      style: TextStyle(fontSize: 40),
                    ),
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              QuerySnapshot qs = snapshot.data;
              if (snapshot.hasError) return Text("Erro ao carregar dados");

              if (qs.documents.length == 0)
                return Text("Você é fracassado e não tem amigos ainda :((");

              return ListView.builder(
                  itemCount: qs.documents.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouteGenerator.MESSAGES_ROUTE,
                            arguments: {
                              "contactName": qs.documents[index]['contactName'],
                              "profilePicURL": qs.documents[index]
                                  ['contactProfilePhoto'],
                              "userId": widget.user['userId'],
                              "contactId": qs.documents[index]['contactId'],
                              "username": widget.user["name"],
                              "userPic": widget.user["profilePicURL"]
                            });
                      },
                      contentPadding: EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        8,
                      ),
                      leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.green,
                        backgroundImage: NetworkImage(
                            qs.documents[index]['contactProfilePhoto']),
                      ),
                      title: Text(
                        qs.documents[index]['contactName'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: qs.documents[index]['type'] == "text"
                          ? Text(qs.documents[index]['message'])
                          : Text("Imagem recebida"),
                    );
                  });
          }
          return Container();
        });
  }
}
