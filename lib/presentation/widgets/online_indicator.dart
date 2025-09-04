import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class OnlineIndicator extends StatelessWidget {
  const OnlineIndicator({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final databaseReference = FirebaseDatabase.instance.ref('status/$userId');

    return StreamBuilder<DatabaseEvent>(
      stream: databaseReference.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          // Default to offline if no data is available
          return _buildIndicator(false);
        }

        final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        final isOnline = data['isOnline'] as bool? ?? false;

        return _buildIndicator(isOnline);
      },
    );
  }

  Widget _buildIndicator(bool isOnline) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline ? Colors.green : Colors.grey,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }
}
