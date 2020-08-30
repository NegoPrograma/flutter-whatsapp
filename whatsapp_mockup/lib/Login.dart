import 'package:flutter/material.dart';
import 'package:whatsapp_mockup/Register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp_mockup/Utils/RouteGenerator.dart';
import 'Models/User.dart';
import 'package:whatsapp_mockup/Home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _resultMessage = "";
  void _signIn(User user) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .signInWithEmailAndPassword(email: user.email, password: user.password)
        .then((FirebaseUser user) {
      Navigator.pushReplacementNamed(context, RouteGenerator.HOME_ROUTE);
    }).catchError((onError) => setState(() {
              _resultMessage = "Erro, favor tentar novamente.";
            }));
  }

  Future _checkUserSession() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    if (loggedUser != null)
      Navigator.pushReplacementNamed(context, RouteGenerator.HOME_ROUTE);
  }

  @override
  void initState() {
    super.initState();
    _checkUserSession();
    _emailController.text = "lek@gmail.com";
    _passwordController.text = "testes";
  }

  void _validateFields() {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isNotEmpty && email.contains('@')) {
      if (password.isNotEmpty) {
        User newUser = User.loginConstructor(email, password);
        _signIn(newUser);
      } else {
        _resultMessage = "Preencha a senha.\n";
      }
    } else {
      _resultMessage = "Preencha um email válido.\n";
    }
    setState(() {
      _resultMessage = _resultMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xff075E54),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "assets/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _emailController,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "E-mail",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  style: TextStyle(fontSize: 20),
                  obscureText: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "Senha",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10, top: 16),
                  child: RaisedButton(
                    onPressed: () {
                      _validateFields();
                    },
                    child: Text(
                      "Entrar",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.greenAccent,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                          context, RouteGenerator.REGISTER_ROUTE);
                    },
                    child: Text(
                      "Não tem conta? Clique aqui e cadastre-se!",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      _resultMessage,
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
