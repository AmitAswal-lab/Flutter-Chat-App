import 'package:chat_app/theme/theme1/app_colors.dart';
import 'package:flutter/material.dart';

Color _getUserColor(String userId) {
  final int hash = userId.hashCode;
  final int index = hash % AppColors.chatUsernameColors.length;
  return AppColors.chatUsernameColors[index.abs()];
}

class MessageBubble extends StatelessWidget {
  const MessageBubble.first({
    super.key,
    required this.messageData,
    required this.isMe,
  }) : isFirstInSequence = true;

  const MessageBubble.next({
    super.key,
    required this.messageData,
    required this.isMe,
  }) : isFirstInSequence = false;

  final bool isFirstInSequence;
  final Map<String, dynamic> messageData;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final messageType = messageData['type'] as String? ?? 'text';
    final userImage =
        isFirstInSequence ? messageData['userImage'] as String? : null;
    final username =
        isFirstInSequence ? messageData['username'] as String? : null;
    final userId = messageData['userId'] as String;

    Widget buildReadReceipt() {
      if (!isMe) {
        return const SizedBox.shrink();
      }
      final readBy = messageData['readBy'] as List<dynamic>? ?? [];
      final bool isRead = readBy.length > 1;

      return Padding(
        padding: const EdgeInsets.only(left: 5, top: 4),
        child: Icon(
          isRead ? Icons.done_all : Icons.done,
          size: 18,
          color: isRead
              ? const Color.fromARGB(255, 84, 104, 12)
              : Colors.white.withAlpha(189),
        ),
      );
    }

    final borderRadius = BorderRadius.only(
      topLeft:
          !isMe && isFirstInSequence ? Radius.zero : const Radius.circular(12),
      topRight:
          isMe && isFirstInSequence ? Radius.zero : const Radius.circular(12),
      bottomLeft: const Radius.circular(12),
      bottomRight: const Radius.circular(12),
    );

    final avatarRadius = 15;
    final avatarSpace = (avatarRadius * 2) + 4.0;

    return Stack(
      children: [
        if (userImage != null && !isMe)
          Positioned(
            top: 10,
            left: 0,
            child: CircleAvatar(
              backgroundImage: NetworkImage(userImage),
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 15,
            ),
          ),
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMe) SizedBox(width: avatarSpace),
            Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (isFirstInSequence) const SizedBox(height: 8),
                if (username != null && !isMe)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8, right: 13, bottom: 4),
                    child: Text(
                      username,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _getUserColor(userId),
                      ),
                    ),
                  ),
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.chatMeBubbleLightBlue
                        : AppColors.chatOtherBubbleDark,
                    borderRadius: borderRadius,
                  ),
                  constraints: const BoxConstraints(maxWidth: 250),
                  margin:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  child: messageType == 'image'
                      ? Image.network(
                          messageData['imageUrl'],
                          fit: BoxFit.cover,
                          height: 250,
                          width: 250,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 250,
                              height: 250,
                              color: Colors.grey[800],
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 250,
                              height: 250,
                              color: Colors.grey[800],
                              child: const Center(
                                  child:
                                      Icon(Icons.error, color: Colors.white)),
                            );
                          },
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 14,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  messageData['text'],
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
                              buildReadReceipt(),
                            ],
                          ),
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
