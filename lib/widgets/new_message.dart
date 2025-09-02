import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({
    super.key,
    required this.chatRoomId,
    this.replyingTo,
    this.onReplySent,
  });

  final String chatRoomId;
  final ({Map<String, dynamic> messageData, String messageId})? replyingTo;
  final Function()? onReplySent;

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  Timer? _typingTimer;
  var _isSendingImage = false;
  final _currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void dispose() {
    _messageController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _submitMessage({String? imageUrl}) async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty && imageUrl == null) {
      return;
    }

    Map<String, dynamic>? replyContext;
    if (widget.replyingTo != null) {
      replyContext = {
        'repliedToMessageId': widget.replyingTo!.messageId,
        'repliedToMessage': widget.replyingTo!.messageData['type'] == 'image'
            ? '📷 Photo'
            : widget.replyingTo!.messageData['text'],
        'repliedToSender': widget.replyingTo!.messageData['username'],
        'repliedToSenderId': widget.replyingTo!.messageData['userId'],
      };
    }

    _typingTimer?.cancel();
    FirebaseFirestore.instance.collection('chats').doc(widget.chatRoomId).set({
      'typing': FieldValue.arrayRemove([_currentUser.uid])
    }, SetOptions(merge: true));

    FocusScope.of(context).unfocus();
    _messageController.clear();

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser.uid)
        .get();

    final messageData = {
      'type': imageUrl != null ? 'image' : 'text',
      'text': enteredMessage,
      'imageUrl': imageUrl, // This will be null for text messages
      'createAt': Timestamp.now(),
      'userId': _currentUser.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['imageURL'],
      'readBy': [_currentUser.uid],
      'replyContext': replyContext,
    };

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatRoomId)
        .collection('messages')
        .add(messageData);
    widget.onReplySent?.call();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatRoomId)
        .update({
      'lastMessage': imageUrl != null ? '📷 Photo' : enteredMessage,
      'lastMessageTimestamp': Timestamp.now(),
    });
    if (widget.onReplySent != null) {
      widget.onReplySent!();
    }
  }

  void _sendImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 1000,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _isSendingImage = true;
    });

    try {
      final imageFile = File(pickedImage.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child(widget.chatRoomId)
          .child(fileName);

      await storageRef.putFile(imageFile);
      final imageUrl = await storageRef.getDownloadURL();

      _submitMessage(imageUrl: imageUrl);
    } catch (error) {
      print("----------- IMAGE UPLOAD FAILED -----------");
      print(error);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to send image. Please try again.')),
        );
      }
    } finally {
      setState(() {
        _isSendingImage = false;
      });
    }
  }

  void _handleTyping(String value) {
    final chatDocRef =
        FirebaseFirestore.instance.collection('chats').doc(widget.chatRoomId);

    if (_typingTimer == null || !_typingTimer!.isActive) {
      chatDocRef.set({
        'typing': FieldValue.arrayUnion([_currentUser.uid])
      }, SetOptions(merge: true));
    }

    _typingTimer?.cancel();

    _typingTimer = Timer(const Duration(seconds: 2), () {
      chatDocRef.set({
        'typing': FieldValue.arrayRemove([_currentUser.uid])
      }, SetOptions(merge: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 15,
        left: 15,
        right: 1,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed:
                _isSendingImage ? null : _sendImage, // Disable while sending
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              onChanged: _handleTyping,
              decoration: const InputDecoration(hintText: 'Send a message...'),
            ),
          ),
          // Show a progress indicator when sending an image, otherwise show the send button
          if (_isSendingImage)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )
          else
            IconButton(
              iconSize: 35,
              color: Theme.of(context).colorScheme.primary,
              onPressed: () => _submitMessage(),
              icon: const Icon(Icons.send),
            ),
        ],
      ),
    );
  }
}
