import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'add_event_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddEventPage(
                            onEventAdded: () {
                              // Hier könnte die Logik stehen, um die Übersicht der nächsten Termine zu aktualisieren
                            },
                          )),
                );
              },
              child: const Text('Termin hinzufügen'),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('Keine bevorstehenden Termine.');
                }
                final events = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      title: Text(event['eventType'] == 'training'
                          ? 'Trainingseinheit'
                          : 'Spiel: ${event['matchup']}'),
                      subtitle: Text(
                          '${event['location']} - ${event['date'].toDate()}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
