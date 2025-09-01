import 'package:chat_app/widgets/chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key, required this.chatRoomId});
  final String chatRoomId;

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  final _currentUser = FirebaseAuth.instance.currentUser!;

  void _markMessagesAsRead(List<QueryDocumentSnapshot> messages) {
    final batch = FirebaseFirestore.instance.batch();

    for (var messageDoc in messages) {
      final messageData = messageDoc.data() as Map<String, dynamic>;

      final readByList = messageData['readBy'] as List<dynamic>? ?? [];

      if (messageData['userId'] != _currentUser.uid &&
          !readByList.contains(_currentUser.uid)) {
        batch.update(messageDoc.reference, {
          'readBy': FieldValue.arrayUnion([_currentUser.uid])
        });
      }
    }
    batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatRoomId)
          .collection('messages')
          .orderBy('createAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found!'));
        }
        if (chatSnapshots.hasError) {
          // This will show the actual error in the UI for debugging
          return Center(child: Text('Error: ${chatSnapshots.error}'));
        }
        final loadedMessages = chatSnapshots.data!.docs;

        _markMessagesAsRead(loadedMessages);

        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 40,
            right: 12,
            left: 12,
          ),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index].data();
            final nextMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;

            final currentMessageUserId = chatMessage['userId'];
            final nextMessageuserId = nextMessage?['userId'];
            final nextUserIsSame = currentMessageUserId == nextMessageuserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                messageData: chatMessage,
                isMe: _currentUser.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                messageData: chatMessage,
                isMe: _currentUser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
