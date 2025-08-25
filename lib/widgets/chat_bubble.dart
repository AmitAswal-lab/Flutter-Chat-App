import 'package:chat_app/theme/theme1/app_colors.dart';
import 'package:flutter/material.dart';

// Helper function to get a consistent color for a user ID
Color _getUserColor(String userId) {
  final int hash = userId.hashCode;
  final int index = hash % AppColors.chatUsernameColors.length;
  return AppColors.chatUsernameColors[index.abs()];
}

class MessageBubble extends StatelessWidget {
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
    required this.userId,
  }) : isFirstInSequence = true;

  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
    required this.userId,
  }) : isFirstInSequence = false,
       userImage = null,
       username = null;

  final bool isFirstInSequence;
  final String? userImage;
  final String? username;
  final String message;
  final bool isMe;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarRadius = 15;
    final avatarSpace = (avatarRadius * 2) + 4.0;

    return Stack(
      children: [
        if (userImage != null && !isMe)
          Positioned(
            top: 10,

            left: 0,
            child: CircleAvatar(
              backgroundImage: NetworkImage(userImage!),
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 15,
            ),
          ),
        Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!isMe) SizedBox(width: avatarSpace),

            Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (isFirstInSequence) const SizedBox(height: 8),
                if (username != null && !isMe)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 13,
                      bottom: 4,
                    ),
                    child: Text(
                      username!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _getUserColor(userId!),
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.chatMeBubbleLightBlue
                        : AppColors.chatOtherBubbleDark,
                    borderRadius: BorderRadius.only(
                      topLeft: !isMe && isFirstInSequence
                          ? Radius.zero
                          : const Radius.circular(12),
                      topRight: isMe && isFirstInSequence
                          ? Radius.zero
                          : const Radius.circular(12),
                      bottomLeft: const Radius.circular(12),
                      bottomRight: const Radius.circular(12),
                    ),
                  ),
                  constraints: const BoxConstraints(maxWidth: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 4,
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      height: 1.3,
                      color: isMe
                          ? AppColors.chatBubbleTextLight
                          : AppColors.chatBubbleTextDark,
                      fontSize: 15,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
