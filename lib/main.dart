import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';


import 'screens/welcome_screen.dart';

void main()async {
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
        builder: (context , snapshot){
          return MaterialApp(
            initialRoute: WelcomeScreen.id,
            routes:{
              WelcomeScreen.id : (context) => WelcomeScreen(),
              LoginScreen.id : (context) => LoginScreen(),
              RegistrationScreen.id : (context) => RegistrationScreen(),
              ChatScreen.id : (context) => ChatScreen(),
            },
          );
        }
    );
  }
}
