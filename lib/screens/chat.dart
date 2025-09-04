import 'package:chat_app/widgets/new_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_app/widgets/online_indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'package:chat_app/widgets/swipeable_message_bubble.dart';

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
  final _currentUser = FirebaseAuth.instance.currentUser!;
  ({Map<String, dynamic> messageData, String messageId})? _replyingToMessage;

  final ScrollController _scrollController = ScrollController();
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _messagesStream;

  bool _isReplying = false;

  @override
  void initState() {
    super.initState();
    _messagesStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatRoomId)
        .collection('messages')
        .orderBy('createAt', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startReplyingTo({
    required Map<String, dynamic> messageData,
    required String messageId,
  }) {
    if (!_isReplying) {
      setState(() {
        _replyingToMessage = (messageData: messageData, messageId: messageId);
        _isReplying = true;
      });
    }
  }

  void _cancelReply() {
    setState(() {
      _replyingToMessage = null;
      _isReplying = false;
    });
  }

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

  void _showMessageOptions(
    BuildContext context,
    Map<String, dynamic> messageData,
    String messageId,
  ) {
    final messageType = messageData['type'] as String? ?? 'text';
    final isMe = _currentUser.uid == messageData['userId'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850],
      builder: (ctx) => Wrap(
        children: <Widget>[
          if (!isMe)
            ListTile(
              leading: const Icon(Icons.reply, color: Colors.white),
              title: const Text('Reply', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(ctx).pop();
                _startReplyingTo(
                    messageData: messageData, messageId: messageId);
              },
            ),
          if (messageType == 'text')
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.white),
              title: const Text('Copy', style: TextStyle(color: Colors.white)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: messageData['text']));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Text copied to clipboard'),
                      duration: Duration(seconds: 1)),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Row(
                children: [
                  Text(widget.otherUsername ?? 'Chat'),
                  if (widget.otherUserId != null)
                    OnlineIndicator(userId: widget.otherUserId!),
                ],
              ),
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _messagesStream,
              builder: (ctx, chatSnapshots) {
                if (chatSnapshots.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!chatSnapshots.hasData ||
                    chatSnapshots.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages found!'));
                }
                if (chatSnapshots.hasError) {
                  return const Center(child: Text('Something went wrong...'));
                }
                final loadedMessages = chatSnapshots.data!.docs;
                _markMessagesAsRead(loadedMessages);

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.only(bottom: 10, right: 12, left: 12),
                  reverse: true,
                  itemCount: loadedMessages.length,
                  itemBuilder: (ctx, index) {
                    final messageDoc = loadedMessages[index];
                    final chatMessage = messageDoc.data();
                    final nextMessage = index + 1 < loadedMessages.length
                        ? loadedMessages[index + 1].data()
                        : null;
                    final currentMessageUserId =
                        chatMessage['userId'] as String? ?? '';
                    final nextMessageUserId =
                        nextMessage?['userId'] as String? ?? '';

                    // If a message has no user ID, it's corrupted, so we skip it.
                    if (currentMessageUserId.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final isMe = _currentUser.uid == currentMessageUserId;
                    final isFirstInSequence = nextMessage == null ||
                        nextMessageUserId != currentMessageUserId;

                    return SwipeableMessageBubble(
                      key: ValueKey(messageDoc.id),
                      messageData: chatMessage,
                      isMe: isMe,
                      isFirstInSequence: isFirstInSequence,
                      onReply: () {
                        _startReplyingTo(
                          messageData: chatMessage,
                          messageId: messageDoc.id,
                        );
                      },
                      onLongPress: () {
                        _showMessageOptions(
                            context, chatMessage, messageDoc.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
          _buildTypingIndicator(),
          _buildReplyPreview(),
          NewMessage(
            chatRoomId: widget.chatRoomId,
            replyingTo: _replyingToMessage,
            onReplySent: () {
              _cancelReply();
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }

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
            child: Text('Typing...',
                style:
                    TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildReplyPreview() {
    final isReplying = _replyingToMessage != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: isReplying ? 70 : 0,
      child: isReplying
          ? FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: ClipRRect(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        color: _getUserColor(
                            _replyingToMessage!.messageData['userId']),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _replyingToMessage!.messageData['username'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getUserColor(
                                    _replyingToMessage!.messageData['userId']),
                              ),
                            ),
                            Text(
                              _replyingToMessage!.messageData['type'] == 'image'
                                  ? '📷 Photo'
                                  : _replyingToMessage!.messageData['text'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _cancelReply,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Color _getUserColor(String userId) {
    final int hash = userId.hashCode;
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal
    ];
    return colors[hash % colors.length];
  }
}
