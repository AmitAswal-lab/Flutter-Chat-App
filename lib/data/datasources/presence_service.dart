import 'package:firebase_database/firebase_database.dart';

class PresenceService {
  final String _uid;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  late final DatabaseReference _userStatusRef;

  PresenceService(this._uid) {
    _userStatusRef = _db.child('status/$_uid');
  }

  // Sets the user's status to online and configures onDisconnect
  void setOnline() {
    print('--- [Presence] Setting status to ONLINE for $_uid ---');
    final status = {
      'isOnline': true,
      'last_seen': ServerValue.timestamp,
    };

    // It will execute even if the app crashes or loses connection
    _userStatusRef.onDisconnect().set({
      'isOnline': false,
      'last_seen': ServerValue.timestamp,
    });

    // Set the initial online status
    _userStatusRef.set(status);
  }

  // Sets the user's status to offline
  void setOffline() {
    final status = {
      'isOnline': false,
      'last_seen': ServerValue.timestamp,
    };
    _userStatusRef.set(status);
  }
}
