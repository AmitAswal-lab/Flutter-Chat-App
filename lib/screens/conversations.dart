import 'package:flutter/material.dart';

import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/private_chat.dart';
import 'package:chat_app/screens/user_search.dart';
import 'package:chat_app/screens/profile_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  int _selectedIndex = 0;
  var _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _setupPushNotifications();
  }

  void _setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    final token = await fcm.getToken();

    if (token != null) {
      final currentUser = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'fcmToken': token});
    }
  }

  static const List<Widget> _pages = <Widget>[
    PrivateChatScreen(),
    ChatScreen(chatRoomId: 'global_chat', showAppBar: false),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _signOut() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to log out: $error')));
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Chats' : 'Global Chat'),
        leading: IconButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (ctx) => const ProfileScreen()));
          },
          icon: const Icon(Icons.account_circle),
        ),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const UserSearchScreen()),
                );
              },
              icon: const Icon(Icons.search),
            ),
          if (_isLoggingOut)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            )
          else
            IconButton(
              onPressed: _signOut,
              icon: const Icon(Icons.exit_to_app),
            ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Private'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Global'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
