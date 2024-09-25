import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerDetails extends StatelessWidget {
  final DocumentSnapshot player;

  const PlayerDetails({Key? key, required this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> teamIds = List<String>.from(player['teams']);
    final CollectionReference teamsRef =
        FirebaseFirestore.instance.collection('teams');

    return Scaffold(
      appBar: AppBar(
        title: Text(player['name']),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Name: ${player['name']}', style: TextStyle(fontSize: 18)),
            Text('Alter: ${player['age']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Teams:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: teamsRef
                    .where(FieldPath.documentId, whereIn: teamIds)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final teams = snapshot.data!.docs;
                    return ListView(
                      children: teams
                          .map((team) => ListTile(title: Text(team['name'])))
                          .toList(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Fehler beim Laden der Teams');
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
