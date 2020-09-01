import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Models/User.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Config extends StatefulWidget {
  @override
  _ConfigState createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  TextEditingController _usernameController = TextEditingController();
  String userId = "", profilePicURL = "";
  File _image;
  @override
  void initState() {
    super.initState();
    fillInitialValues();
  }

  void fillInitialValues() async {
    getUsername();
  }

  Future _getImage(String imageSource) async {
    if (imageSource == "camera") {
      _image = await ImagePicker.pickImage(source: ImageSource.camera);
    } else {
      _image = await ImagePicker.pickImage(source: ImageSource.gallery);
    }

    setState(() {
      _image = _image;
      if (_image != null) _uploadImage(_image);
    });
  }

  Future _uploadImage(File _image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference storageRoot = storage.ref();
    StorageReference file = storageRoot.child("photos").child("$userId.jpg");

    StorageUploadTask task = file.putFile(_image);

    //Recuperar url da imagem
    task.onComplete.then((StorageTaskSnapshot snapshot) {
      getProfilePicURL(snapshot);
    });
  }

  void getUsername() {
    FirebaseAuth auth = FirebaseAuth.instance;
    Firestore db = Firestore.instance;

    auth.currentUser().then((user) async {
      DocumentSnapshot userData =
          await db.collection("users").document(user.uid).get();
      _usernameController.text = userData.data['name'];
      userId = user.uid;
    }).catchError((onError) {
      print("Erro! $onError");
    });
  }

  void getProfilePicURL(StorageTaskSnapshot snapshot) async {
    profilePicURL = await snapshot.ref.getDownloadURL();
    
    _getProfilePic();
  }

  dynamic _profilePic = null;

  dynamic _getProfilePic() {
    if (profilePicURL != null) {
      setState(() {
        _profilePic = NetworkImage(profilePicURL);
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
      ),
      body: Center(
        child: Container(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(8, 150, 8, 100),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 100,
                  backgroundImage: _profilePic,
                  backgroundColor: Colors.greenAccent[300],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FlatButton(
                        onPressed: () {
                          _getImage("camera");
                        },
                        child: Text("Câmera"),
                      ),
                      FlatButton(
                        onPressed: () {
                          _getImage("gallery");
                        },
                        child: Text("Galeria"),
                      ),
                    ]),
                TextField(
                  controller: _usernameController,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "Seu nome",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
                RaisedButton(
                  onPressed: () {},
                  child: Text(
                    "Salvar",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.greenAccent,
                  padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      //body: Center(child: Column(children: [CircleAvatar()],),),
    );
  }
}
