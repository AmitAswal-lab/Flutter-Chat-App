import 'package:chat_app/widgets/new_message.dart';
import 'package:chat_app/widgets/chat_messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/widgets/online_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.chatRoomId,
    this.showAppBar = true,
    this.otherUsername,
    this.otherUserId,
  });

  final String chatRoomId;
  final bool showAppBar;
  final String? otherUsername;
  final String? otherUserId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Widget _buildTypingIndicator() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatRoomId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final typingUsers = (data['typing'] as List<dynamic>?) ?? [];

        final isSomeoneElseTyping =
            typingUsers.any((uid) => uid != currentUserId);

        if (isSomeoneElseTyping) {
          return const Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(
              'Typing...',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ChatMessages(chatRoomId: widget.chatRoomId),
        ),
        _buildTypingIndicator(),
        NewMessage(chatRoomId: widget.chatRoomId),
      ],
    );

    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(widget.otherUsername ?? 'Chat'),
              if (widget.otherUserId != null)
                OnlineIndicator(userId: widget.otherUserId!),
            ],
          ),
        ),
        body: chatContent,
      );
    } else {
      return chatContent;
    }
  }
}
