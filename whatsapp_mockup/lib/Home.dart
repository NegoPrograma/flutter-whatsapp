import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp_mockup/Login.dart';
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

  Widget _generateContacts(BuildContext context, List<Map> contactList) {
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
        );
      },
    );
  }

  void _getChosenOption(String chosenOption) {
    switch (chosenOption) {
      case "Configurações":
        break;
      case "Deslogar":
        _signOut();
        break;
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, RouteGenerator.HOME_ROUTE);
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
          _generateContacts(context, test),
        ],
      ),
    );
  }
}
