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
                              // Logik zur Aktualisierung der Übersicht hinzufügen
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
                return SingleChildScrollView(
                  scrollDirection: Axis
                      .horizontal, // Damit die Tabelle scrollbar wird, wenn sie zu breit ist
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Spielpaarung')),
                      DataColumn(label: Text('Uhrzeit')),
                      DataColumn(label: Text('Datum')),
                      DataColumn(label: Text('Ort')),
                    ],
                    rows: events.map((event) {
                      final eventType = event['eventType'];
                      final matchup = eventType == 'match'
                          ? event['matchup']
                          : 'Trainingseinheit';
                      final dateTime = event['date'].toDate();
                      final date =
                          '${dateTime.day}.${dateTime.month}.${dateTime.year}';
                      final time =
                          '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
                      final location = event['location'];

                      return DataRow(cells: [
                        DataCell(Text(matchup)),
                        DataCell(Text(time)),
                        DataCell(Text(date)),
                        DataCell(Text(location)),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
