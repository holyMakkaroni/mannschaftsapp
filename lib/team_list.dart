import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'team_details.dart';
import 'add_team_page.dart';

class TeamList extends StatefulWidget {
  const TeamList({Key? key}) : super(key: key);

  @override
  _TeamListState createState() => _TeamListState();
}

class _TeamListState extends State<TeamList> {
  final CollectionReference teamsRef =
      FirebaseFirestore.instance.collection('teams');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teams'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: teamsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final teams = snapshot.data!.docs;
            return ListView.builder(
              itemCount: teams.length,
              itemBuilder: (context, index) {
                var team = teams[index];
                return ListTile(
                  title: Text(team['name']),
                  subtitle: Text(team['description'] ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TeamDetails(teamId: team.id)),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler beim Laden der Teams'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTeamPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
