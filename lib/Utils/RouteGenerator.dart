import 'package:flutter/material.dart';
import 'package:whatsapp_mockup/Config.dart';
import 'package:whatsapp_mockup/Home.dart';
import 'package:whatsapp_mockup/Login.dart';
import 'package:whatsapp_mockup/Register.dart';
import 'package:whatsapp_mockup/Messages.dart';

class RouteGenerator {
  static const HOME_ROUTE = "/home";
  static const LOGIN_ROUTE = "/login";
  static const REGISTER_ROUTE = "/register";
  static const ROOT_ROUTE = "/";
  static const CONFIG_ROUTE = "/config";
  static const MESSAGES_ROUTE = "/messages";

  static Route<dynamic> _routeError() {
    return MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Tela não encontrada!"),
          ),
          body: Center(
            child: Text("Tela não encontrada!"),
          ),
        );
      },
    );
  }

  static Route<dynamic> generateRoute(RouteSettings currentRoute) {
    final args = currentRoute.arguments;
    switch (currentRoute.name) {
      case ROOT_ROUTE:
        return MaterialPageRoute(
          builder: (context) => LoginScreen(),
        );
        break;
      case LOGIN_ROUTE:
        return MaterialPageRoute(
          builder: (context) => LoginScreen(),
        );
        break;
      case REGISTER_ROUTE:
        return MaterialPageRoute(
          builder: (context) => Register(),
        );
        break;
      case HOME_ROUTE:
        return MaterialPageRoute(
          builder: (context) => Home(),
        );
        break;
      case CONFIG_ROUTE:
        return MaterialPageRoute(
          builder: (context) => Config(),
        );
        break;
      case MESSAGES_ROUTE:
        return MaterialPageRoute(
          builder: (context) => Messages(args),
        );
        break;

      default:
        return _routeError();
    }
  }
}
