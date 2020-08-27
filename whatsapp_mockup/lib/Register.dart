import 'package:flutter/material.dart';
import 'dart:async';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _resultMessage = "";
  _validateFields() {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (name.isNotEmpty && name.length > 3) {
      if (email.isNotEmpty && email.contains('@')) {
        if (password.isNotEmpty && password.length > 5) {
          _resultMessage = "Sucesso! Seja bem vindo(a) ao zapzap";
        } else {
          _resultMessage = "Senha deve possuir no mínimo 6 caracteres.\n";
        }
      } else {
        _resultMessage = "Preencha um email válido.\n";
      }
    } else {
      _resultMessage = "Nome deve possuir no mínimo 3 caracteres\n";
    }
    setState(() {
      _resultMessage = _resultMessage;
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff075E54),
        title: Text('Cadastro'),
      ),
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
                    "assets/usuario.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _nameController,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Nome",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
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
                  keyboardType: TextInputType.emailAddress,
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
                      "Cadastrar",
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
                  child: Text(
                    _resultMessage,
                    style: TextStyle(color: Colors.red, fontSize: 20),
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
