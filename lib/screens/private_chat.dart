import 'package:flutter/material.dart';

import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/widgets/online_indicator.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrivateChatScreen extends StatelessWidget {
  const PrivateChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUser.uid)
          .orderBy('lastMessageTimestamp', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(child: Text('No chats found. Start a new one!'));
        }
        if (chatSnapshots.hasError) {
          return const Center(child: Text('Something went wrong...'));
        }

        final loadedChats = chatSnapshots.data!.docs;

        final privateChats =
            loadedChats.where((doc) => doc.id != 'global_chat').toList();

        if (privateChats.isEmpty) {
          return const Center(
            child: Text('No private chats found. Start a new one!'),
          );
        }

        return ListView.builder(
          itemCount: privateChats.length,
          itemBuilder: (ctx, index) {
            final chatDoc = privateChats[index];
            final chatData = chatDoc.data();
            final participants = chatData['participants'] as List<dynamic>;

            final otherUserId = participants.firstWhere(
              (id) => id != currentUser.uid,
            );

            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(otherUserId)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    leading: CircleAvatar(),
                    title: Text('Loading...'),
                  );
                }

                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text('User not found'));
                }
                final userData = userSnapshot.data!.data();

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(userData!['imageURL']),
                  ),
                  title: Row(
                    children: [
                      Text(userData['username']),
                      OnlineIndicator(userId: otherUserId),
                    ],
                  ),
                  subtitle: Text(chatData['lastMessage'] ?? ''),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ChatScreen(
                          chatRoomId: chatDoc.id,
                          otherUsername: userData['username'],
                          otherUserId: otherUserId,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
