import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp_mockup/Utils/RouteGenerator.dart';

class Home extends StatefulWidget {
  Home();
  String _email = "";

  Home.verify(this._email);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Map> test;
  List<String> menuItens;
  FirebaseAuth auth;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    menuItens = ["Configurações", "Deslogar"];
    test = [
      {
        'image':
            "https://upload.wikimedia.org/wikipedia/commons/e/e9/Felis_silvestris_silvestris_small_gradual_decrease_of_quality.png",
        'name': "isaac",
        'last_message': 'eae lek'
      },
      {
        'image':
            "https://upload.wikimedia.org/wikipedia/commons/e/e9/Felis_silvestris_silvestris_small_gradual_decrease_of_quality.png",
        'name': "isaac",
        'last_message': 'eae lek'
      },
      {
        'image':
            "https://upload.wikimedia.org/wikipedia/commons/e/e9/Felis_silvestris_silvestris_small_gradual_decrease_of_quality.png",
        'name': "isaac",
        'last_message': 'eae lek'
      },
    ];
    auth = FirebaseAuth.instance;
  }

  Widget _generateConversations(BuildContext context, List<Map> contactList) {
    return ListView.builder(
      itemCount: contactList.length,
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            8,
          ),
          leading: CircleAvatar(
            maxRadius: 30,
            backgroundImage: NetworkImage(contactList[index]['image']),
          ),
          title: Text(
            contactList[index]['name'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(contactList[index]['last_message']),
        );
      },
    );
  }

  Future<List<Map>> _getContacts() async {
    List<Map> contactList = List<Map>();

    Firestore db = Firestore.instance;
    String userId = "";
    await auth.currentUser().then((user) async {
      DocumentSnapshot currentUser =
          await db.collection("users").document(user.uid).get();
      userId = currentUser.data['email'];
      print("\n\n\n\n\n\n\nUsuario atual: " +
          currentUser.data["email"] +
          "\n\n\n\n\n\n\n");
    }).catchError(
      (onError) => print("\n\n\n\n\n\n\n erro $onError\n\n\n\n\n\n\n"),
    );
    QuerySnapshot allUsers = await db.collection("users").getDocuments();

    for (DocumentSnapshot user in allUsers.documents) {
      print("$userId vs " + user.data['email']);
      if (userId != user.data['email'])
        contactList.add(
            {"name": user.data["name"], "image": user.data["profilePicURL"]});
    }
    return contactList;
  }

  FutureBuilder<List<Map>> _generateContacts() {
    return FutureBuilder(
        future: _getContacts(),
        builder: (context, snapshot) {
          List<Map> contacts = snapshot.data;
          print(contacts);
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return ListTile(
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
          _generateConversations(context, test),
          _generateContacts(),
        ],
      ),
    );
  }
}
