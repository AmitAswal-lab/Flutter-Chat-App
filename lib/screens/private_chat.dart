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

            if (!chatData.containsKey('participants') ||
                chatData['participants'] is! List) {
              return const SizedBox.shrink();
            }

            final participants = chatData['participants'] as List<dynamic>;

            if (participants.length < 2) {
              return const SizedBox.shrink();
            }

            final otherUserId = participants.firstWhere(
              (id) => id != currentUser.uid,
              orElse: () => '',
            );

            if (otherUserId.isEmpty) {
              return const SizedBox.shrink();
            }

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
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const ListTile(title: Text('User not found'));
                }

                final userData = userSnapshot.data!.data()!;
                final username =
                    userData['username'] as String? ?? 'Deleted User';
                final imageUrl = userData['imageURL'] as String? ?? '';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                    child: imageUrl.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  title: Row(
                    children: [
                      Text(username),
                      OnlineIndicator(userId: otherUserId),
                    ],
                  ),
                  subtitle: Text(chatData['lastMessage'] ?? ''),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ChatScreen(
                          chatRoomId: chatDoc.id,
                          otherUsername: username,
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
