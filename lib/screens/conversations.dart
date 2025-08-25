import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/private_chat.dart';
import 'package:chat_app/screens/user_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    PrivateChatScreen(),
    ChatScreen(chatRoomId: 'global_chat', showAppBar: false),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Chats' : 'Global Chat'),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const UserSearchScreen()),
                );
              },
              icon: Icon(Icons.search),
            ),
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.exit_to_app),
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
