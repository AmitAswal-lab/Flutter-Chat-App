import 'package:chat_app/widgets/chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key,  required this.chatRoomId});

  final String chatRoomId;

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createAt', descending: true)
        .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return Center(child: Text('No messages found!'));
        }
        if (chatSnapshots.hasError) {
          return Center(child: Text('Something went wrong...'));
        }
        final loadedMessages = chatSnapshots.data!.docs;
        return ListView.builder(
          padding: EdgeInsets.only(
            bottom: 40,
            right: 12,
            left: 12,
          ),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index].data();
            final nextMessage = index + 1 < loadedMessages.length ? loadedMessages[index + 1].data() : null;

            final currentMessageUserId = chatMessage['userId'];
            final nextMessageuserId = nextMessage?['userId'];
            final nextUserIsSame = currentMessageUserId == nextMessageuserId;

            if(nextUserIsSame){
              return MessageBubble.next(
                message: chatMessage['text'],
                userId: chatMessage['userId'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            }else{
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username: chatMessage['username'], 
                message: chatMessage['text'], 
                userId: chatMessage['userId'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
