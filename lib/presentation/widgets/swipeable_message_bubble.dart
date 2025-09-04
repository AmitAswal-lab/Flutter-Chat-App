import 'package:chat_app/presentation/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';

class SwipeableMessageBubble extends StatefulWidget {
  const SwipeableMessageBubble({
    super.key,
    required this.messageData,
    required this.isMe,
    required this.isFirstInSequence,
    required this.onReply,
    required this.onLongPress,
  });

  final Map<String, dynamic> messageData;
  final bool isMe;
  final bool isFirstInSequence;
  final VoidCallback onReply;
  final VoidCallback onLongPress;

  @override
  State<SwipeableMessageBubble> createState() => _SwipeableMessageBubbleState();
}

class _SwipeableMessageBubbleState extends State<SwipeableMessageBubble> {
  double _dragOffsetX = 0.0;
  bool _isDragging = false;
  final double _replyThreshold = 60.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      onHorizontalDragStart: (details) {
        if (!widget.isMe) {
          setState(() {
            _isDragging = true;
          });
        }
      },
      onHorizontalDragUpdate: (details) {
        if (!widget.isMe) {
          setState(() {
            _dragOffsetX = (_dragOffsetX + details.delta.dx).clamp(0.0, 100.0);
          });
        }
      },
      onHorizontalDragEnd: (details) {
        if (!widget.isMe) {
          if (_dragOffsetX > _replyThreshold) {
            widget.onReply();
          }
          setState(() {
            _isDragging = false;
            _dragOffsetX = 0.0;
          });
        }
      },
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          if (_dragOffsetX > 5)
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Icon(
                Icons.reply,
                color: Theme.of(context).colorScheme.primary.withValues(
                    alpha: (_dragOffsetX / _replyThreshold).clamp(0.0, 1.0)),
              ),
            ),
          AnimatedContainer(
            duration:
                _isDragging ? Duration.zero : const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_dragOffsetX, 0, 0),
            child: _buildMessageBubble(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble() {
    if (widget.isFirstInSequence) {
      return MessageBubble.first(
        messageData: widget.messageData,
        isMe: widget.isMe,
      );
    } else {
      return MessageBubble.next(
        messageData: widget.messageData,
        isMe: widget.isMe,
      );
    }
  }
}
