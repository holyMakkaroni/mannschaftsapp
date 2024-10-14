import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spieltermine'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('eventType', isEqualTo: 'game')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Keine Spieltermine gefunden.'));
          }
          final events = snapshot.data!.docs;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text('Spiel: ${event['matchup']}'),
                subtitle:
                    Text('${event['location']} - ${event['date'].toDate()}'),
              );
            },
          );
        },
      ),
    );
  }
}
