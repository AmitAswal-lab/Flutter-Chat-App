import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key, required this.chatRoomId});

  final String chatRoomId;

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {

  var messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void _summitMessage()async{
    final enteredMessage = messageController.text;
    
    if(enteredMessage.trim().isEmpty){
      return;
    }

    FocusScope.of(context).unfocus();
    messageController.clear();

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    
    final messageData ={
      'text' : enteredMessage,
       'createAt' : Timestamp.now(),
       'userId' : user.uid,
       'username' : userData.data()!['username'],
       'userImage': userData.data()!['imageURL'],
    };

    await FirebaseFirestore.instance
      .collection('chats')
      .doc(widget.chatRoomId)
      .collection('messages')
      .add(messageData);
    
    await FirebaseFirestore.instance.
      collection('chats')
      .doc(widget.chatRoomId).
      update({
        'lastMessage' : enteredMessage,
        'lastMessageTimestamp' : Timestamp.now(),
    });
    


  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 15,
        left: 15,
        right: 1,
      ),
      child: Row(
        children: [
          Expanded(child: TextField(
            controller: messageController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: InputDecoration(
              hintText: 'Send a message...'
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          )),
          IconButton(
            iconSize: 35,
            color: Theme.of(context).colorScheme.primary,
            onPressed: _summitMessage,
             icon: Icon(Icons.send)),
        ],
      ),
    );
  }
}