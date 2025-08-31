import 'package:chat_app/theme/theme1/app_colors.dart';
import 'package:chat_app/widgets/new_message.dart';
import 'package:chat_app/widgets/chat_messages.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    required this.chatRoomId,
    this.showAppBar = true,
    this.otherUsername,
  });

  final String chatRoomId;
  final bool showAppBar;
  final String? otherUsername;

  @override
  Widget build(BuildContext context) {
    final chatContent = Column(
      children: [
        Expanded(child: ChatMessages(chatRoomId: chatRoomId)),
        NewMessage(chatRoomId: chatRoomId),
      ],
    );

    if (showAppBar) {
      return Scaffold(
        backgroundColor: AppColors.surfaceDark,
        appBar: AppBar(title: Text(otherUsername ?? 'Chat')),

        body: chatContent,
      );
    } else {
      return chatContent;
    }
  }
}
