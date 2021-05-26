import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const   String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //final _firestore = FirebaseFirestore.instance;
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messageText;

   @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser(){
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        //print(loggedInUser.email);
       // print(user.runtimeType);
      }
    }catch(e){
      print(e);
    }
  }

  // void getMessages() async{
  //    final messeges = await _firestore.collection('messeges').get();
  //    for( var message in messeges.docs){
  //      print(message.data());
  //    }
  //  }

  // void messegesStream() async{
  //   await for( var snapshot in _firestore.collection('messeges').snapshots() ){
  //     for(var message in snapshot.docs){
  //       //print(message.data());
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pushNamed(context , WelcomeScreen.id);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container (
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messeges').add({
                        'text' : messageText,
                        'sender' : loggedInUser.email,
                        'timeStamp' : Timestamp.now(),
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MessageStream extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messeges').orderBy('timeStamp' , descending: true ).snapshots(),
      builder: (context , snapshots) {
        if(!snapshots.hasData){
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlue,
            ),
          );
        }
        final messages = snapshots.data.docs;

        List<MessegeBuble> messegeBubles = [];
        for(int i = 0;messages.length > i ; i++ ){
            final messageText = messages[i]['text'];
            final messageSender = messages[i]['sender'];
            final messegeTime = messages[i]['timeStamp'];

            final dateFormater = DateFormat.yMMMd().add_jm().format(messegeTime.toDate()).toString();

            final currentUser = loggedInUser.email;

            final messegeBuble = MessegeBuble(
            sender: messageSender,
            text: messageText,
              time: dateFormater,
              isMe: currentUser == messageSender,
            );
            messegeBubles.add(messegeBuble);
        }
              //return Text('hello');
              return Expanded(
                child: ListView(
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 10.0 , vertical: 20.0),
                  children: messegeBubles,
                ),
              );
            }
      ,
    );
  }
}




class MessegeBuble extends StatelessWidget {

  MessegeBuble({this.sender,this.text , this.isMe , this.time});

  final String sender;
  final String text;
  final String time;
  final bool isMe;

@override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
           Text( '$sender' , style: TextStyle(fontSize: 12,color:Colors.black45),),
          Material(
            elevation: 5.0,
            borderRadius:isMe ?
            BorderRadius.only(topLeft: Radius.circular(30) , bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30) )
            :BorderRadius.only(topRight: Radius.circular(30) , bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30) )
            ,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
              child: Text('$text' , style: TextStyle(
                  fontSize: 18,
                  color: isMe ? Colors.white : Colors.black54
              ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1 , horizontal: 5) ,
            child: Text(time , style: TextStyle(
              fontSize: 12,
              color: Colors.black38
            ),),
          ),
        ],
      ),
    );
  }
}
