import 'package:flutter/material.dart';

import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/private_chat.dart';
import 'package:chat_app/screens/user_search.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/logic/presence_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  var _isLoggingOut = false;
  late final PresenceService _presenceService;

  @override
  void initState() {
    super.initState();
    _setupPushNotifications();
    _setupInteractedMessage();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _presenceService = PresenceService(uid);
    print('--- [Presence] Initializing PresenceService for UID: $uid ---');
    _presenceService.setOnline();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _presenceService.setOnline();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _presenceService.setOffline();
        break;
      case AppLifecycleState.hidden: // Not on all platforms
        _presenceService.setOffline();
        break;
    }
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

  void _setupInteractedMessage() async {
    // Get any message which caused the application to open from a terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a stream
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    // Read the data payload from the message
    final data = message.data;
    final chatId = data['chatId'];

    if (chatId == null) {
      return;
    }

    if (chatId == 'global_chat') {
      // If it's a global chat notification, switch to the global tab
      setState(() {
        _selectedIndex = 1;
      });
    } else {
      // If it's a private chat, navigate to the ChatScreen
      final otherUsername = data['otherUsername'];
      if (otherUsername == null) {
        print('Error: Notification is missing otherUsername');
        return;
      }
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ChatScreen(
              chatRoomId: chatId,
              otherUsername: otherUsername,
            ),
          ),
        );
      }
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
