import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp_mockup/Conversations.dart';
import 'package:whatsapp_mockup/Utils/RouteGenerator.dart';

class Home extends StatefulWidget {
  Home();
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Map> test;
  List<String> menuItens;
  FirebaseAuth auth;
  String userId = "";
  Map<String, dynamic> user;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    menuItens = ["Configurações", "Deslogar"];
    auth = FirebaseAuth.instance;
    _setUserValues();
  }

  void _setUserValues() async {
    await auth.currentUser().then((value) async {
      Firestore db = Firestore.instance;
      userId = value.uid;
      DocumentSnapshot userSnapshot =
          await db.collection("users").document(userId).get();
      user = userSnapshot.data;
      user["userId"] = userId;
    }).catchError((onError) => print(onError));
   
  }


  Future<List<Map>> _getContacts() async {
    List<Map> contactList = List<Map>();

    Firestore db = Firestore.instance;
    String userEmail = "";
    await auth.currentUser().then((user) async {
      DocumentSnapshot currentUser =
          await db.collection("users").document(user.uid).get();
      userId = user.uid;
      userEmail = currentUser.data['email'];
    }).catchError(
      (onError) => print("\n\n\n\n\n\n\n erro $onError\n\n\n\n\n\n\n"),
    );
    QuerySnapshot allUsers = await db.collection("users").getDocuments();

    for (DocumentSnapshot user in allUsers.documents) {
      if (userEmail != user.data['email'])
        contactList.add({
          "name": user.data["name"],
          "image": user.data["profilePicURL"],
          "contactId": user.documentID,
        });
    }
    return contactList;
  }

  FutureBuilder<List<Map>> _generateContacts() {
    return FutureBuilder(
        future: _getContacts(),
        builder: (context, snapshot) {
          List<Map> contacts = snapshot.data;
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: [
                    Text(
                      "Carregando contatos",
                      style: TextStyle(fontSize: 40),
                    ),
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              return ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(
                          context, RouteGenerator.MESSAGES_ROUTE,
                          arguments: {
                            "contactName": contacts[index]['name'],
                            "profilePicURL": contacts[index]['image'],
                            "userId": userId,
                            "contactId": contacts[index]['contactId'],
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
                      backgroundImage: NetworkImage(contacts[index]['image']),
                    ),
                    title: Text(
                      contacts[index]['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              );
          }
          return Text("Sem contatos ainda");
        });
  }

  void _getChosenOption(String chosenOption) {
    switch (chosenOption) {
      case "Configurações":
        Navigator.pushNamed(this.context, RouteGenerator.CONFIG_ROUTE);
        break;
      case "Deslogar":
        _signOut();
        break;
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, RouteGenerator.LOGIN_ROUTE);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff075E54),
        title: Text("Zapzap"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: "Conversas"), Tab(text: "Contatos")],
        ),
        actions: [
          PopupMenuButton(
              onSelected: (String chosenOption) =>
                  _getChosenOption(chosenOption),
              itemBuilder: (context) {
                return menuItens.map(
                  (String option) {
                    return PopupMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  },
                ).toList();
              }),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Conversations(user),
          _generateContacts(),
        ],
      ),
    );
  }
}
