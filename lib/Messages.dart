import 'dart:async';
import 'dart:io';
import 'dart:core';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp_mockup/Utils/RouteGenerator.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Messages extends StatefulWidget {
  String _contactName = "New User";
  String _profilePicURL = "";
  String _userId = "";
  String _contactId = "";
  String _username = "";
  String _myProfilePicURL = "";

  Messages(contact) {
    _contactName = contact["contactName"];
    _profilePicURL = contact["profilePicURL"];
    _userId = contact['userId'];
    _contactId = contact['contactId'];
    _username = contact['username'];
    _myProfilePicURL = contact['userPic'];
    print(_contactId);
  }
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  TextEditingController _messageController = TextEditingController();
  StreamBuilder messageStream;
  Firestore db = Firestore.instance;
  ScrollController _chatScrollController = ScrollController();
  final StreamController _messageStreamController =
      StreamController<QuerySnapshot>.broadcast();
  File _image;
  void _sendMessage() {
    String message = _messageController.text;

    if (message.isNotEmpty) {
      Map<String, dynamic> messageJSON = {
        "userId": widget._userId,
        'message': message,
        "imageURL": "",
        "type": "text",
        "date": Timestamp.now().toString()
      };

      _storeMessage(widget._userId, widget._contactId, messageJSON);
      _storeMessage(widget._contactId, widget._userId, messageJSON);
      _saveChat(messageJSON);
    }
  }

  Stream<QuerySnapshot> _messageScrollStream() {
    Firestore db = Firestore.instance;

    Stream<QuerySnapshot> stream = db
        .collection("messages")
        .document(widget._userId)
        .collection(widget._contactId)
        .orderBy("date",descending: false)
        .snapshots();
    stream.listen((data) {
      _messageStreamController.add(data);
      Timer(Duration(seconds: 1), () {
        _chatScrollController
            .jumpTo(_chatScrollController.position.maxScrollExtent);
      });
    });
    return stream;
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

  void _sendPhoto() async {
    _image = await ImagePicker.pickImage(source: ImageSource.gallery);

    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _image = _image;
    });
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference storageRoot = storage.ref();
    StorageReference file = storageRoot
        .child("messages")
        .child(widget._userId)
        .child("$imageName.jpg");

    StorageUploadTask task = file.putFile(_image);

    //Recuperar url da imagem
    task.onComplete.then((StorageTaskSnapshot snapshot) {
      getPhotoURL(snapshot);
    });
  }

  void getPhotoURL(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();

    Map<String, dynamic> messageJSON = {
      "userId": widget._userId,
      'message': "",
      "imageURL": url,
      "type": "image",
      "date": Timestamp.now().toString()
    };

    _storeMessage(widget._userId, widget._contactId, messageJSON);
    _storeMessage(widget._contactId, widget._userId, messageJSON);
    _saveChat(messageJSON);
  }

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
        .collection(widget._contactId)
        .snapshots();
  }

  void _saveChat(Map<String, dynamic> lastMessage) async {
    //sender config
    Map<String, dynamic> senderChat = {
      "userId": widget._userId,
      "contactId": widget._contactId,
      "message": lastMessage['message'],
      "contactName": widget._contactName,
      "contactProfilePhoto": widget._profilePicURL,
      "type": lastMessage['type'],
    };

    //receiver config
    Map<String, dynamic> receiverChat = {
      "userId": widget._contactId,
      "contactId": widget._userId,
      "message": lastMessage['message'],
      "contactName": widget._username,
      "contactProfilePhoto": widget._myProfilePicURL,
      "type": lastMessage['type'],
    };

    /**
     * foi preciso colocar esse "last conversation"
     * pois a função setData exige um document antes, 
     * mas a estrutura também exige no minimo duas collections
     * 
     */

    //saving for sender
    await db
        .collection("conversations")
        .document(widget._userId)
        .collection("last_conversation")
        .document(widget._contactId)
        .setData(senderChat);

    //saving for contact
    await db
        .collection("conversations")
        .document(widget._contactId)
        .collection("last_conversation")
        .document(widget._userId)
        .setData(receiverChat);
  }

  void initState() {
    super.initState();

    _messageScrollStream();

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
                messageStream = StreamBuilder(
                    stream: _messageStreamController.stream,
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
                                  controller: _chatScrollController,
                                  itemCount: qs.documents.length,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> message =
                                        qs.documents[index].data;
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
                                          child: message['type'] == 'text'
                                              ? Text(
                                                  message['message'],
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                )
                                              : Image.network(
                                                  message['imageURL']),
                                        ),
                                      ),
                                    );
                                  }),
                            );
                          }
                          break;
                      }
                      return Container();
                    }),
                messageInputField,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
