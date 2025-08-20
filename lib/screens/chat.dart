import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          IconButton(
            onPressed: (){
              FirebaseAuth.instance.signOut();
            }, 
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
      
      body: Center(
         child: Text('Logged in!'),
      ),
    );
  }
}