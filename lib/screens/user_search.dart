import 'package:chat_app/screens/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _searchResults = [];
  bool _isLoading = false;

  void _performSearch() async {
    final query = _searchController.text;
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(
            'username_lowercase',
            isGreaterThanOrEqualTo: query.toLowerCase(),
          )
          .where(
            'username_lowercase',
            isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff',
          )
          .get();

      setState(() {
        _searchResults = userSnapshot.docs
            .where((doc) => doc.id != currentUserId)
            .toList();
      });
    } catch (error) {
      print('Search failed: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startChatWithUser(Map<String, dynamic> userData) async {
    final otherUserId = userData['uid'];

    userData['username'];
    final currentUser = FirebaseAuth.instance.currentUser!;

    List<String> ids = [currentUser.uid, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    final chatDoc = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .get();

    if (!chatDoc.exists) {
      await FirebaseFirestore.instance.collection('chats').doc(chatRoomId).set({
        'participants': [currentUser.uid, otherUserId],
        'lastMessage': 'Chat Started!',
        'lastMessageTimestamp': Timestamp.now(),
      });
    }

    // Navigate to the ChatScreen
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (ctx) => ChatScreen(chatRoomId: chatRoomId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'search ...',
            border: InputBorder.none,
          ),
          onChanged: (value) => _performSearch(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (ctx, index) {
                final userDoc = _searchResults[index];
                final userData = userDoc.data() as Map<String, dynamic>;

                userData['uid'] = userDoc.id;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(userData['imageURL']),
                  ),
                  title: Text(userData['username']),
                  onTap: () => _startChatWithUser(userData),
                );
              },
            ),
    );
  }
}
