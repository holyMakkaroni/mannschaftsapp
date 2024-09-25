import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_team_page.dart';

class TeamDetails extends StatefulWidget {
  final String teamId;

  const TeamDetails({Key? key, required this.teamId}) : super(key: key);

  @override
  _TeamDetailsState createState() => _TeamDetailsState();
}

class _TeamDetailsState extends State<TeamDetails> {
  final CollectionReference teamsRef =
      FirebaseFirestore.instance.collection('teams');
  final CollectionReference teamPlayersRef = FirebaseFirestore.instance.collection(
      'teamPlayers'); // Referenz auf die Sammlung, die die Zuordnungen speichert
  final CollectionReference playersRef = FirebaseFirestore.instance
      .collection('players'); // Referenz auf die Spieler-Sammlung

  DocumentSnapshot? teamData;
  List<DocumentSnapshot> playerDocs = []; // Liste der Spieler-Dokumente

  @override
  void initState() {
    super.initState();
    fetchTeamData();
    fetchTeamPlayers(); // Hole die Spieler, die dem Team zugeordnet sind
  }

  Future<void> fetchTeamData() async {
    var teamSnapshot = await teamsRef.doc(widget.teamId).get();
    setState(() {
      teamData = teamSnapshot;
    });
  }

  Future<void> fetchTeamPlayers() async {
    // Suche nach Zuordnungen in der teamPlayers-Sammlung, die dem Team zugeordnet sind
    var teamPlayerSnapshot =
        await teamPlayersRef.where('teamId', isEqualTo: widget.teamId).get();

    // Hole alle Spieler-Dokumente, die zu dem Team gehören
    List<String> playerIds = teamPlayerSnapshot.docs
        .map((doc) => doc['playerId'] as String)
        .toList();

    // Falls keine Spieler gefunden werden, breche ab
    if (playerIds.isEmpty) {
      return;
    }

    // Hole die Spieler-Dokumente aus der players-Sammlung
    var playersSnapshot =
        await playersRef.where(FieldPath.documentId, whereIn: playerIds).get();

    setState(() {
      playerDocs = playersSnapshot.docs; // Setze die Spieler-Dokumente
    });
  }

  void editTeam() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTeamPage(
          teamId: widget.teamId,
          onTeamUpdated: fetchTeamData,
        ),
      ),
    );
  }

  void deleteTeam() async {
    await teamsRef.doc(widget.teamId).delete();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (teamData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Team Details'),
          centerTitle: true,
        ),
        body: Center(
            child:
                CircularProgressIndicator()), // Ladeindikator, während die Daten geladen werden
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(teamData!['name']),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: editTeam,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: deleteTeam,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(teamData!['description'] ?? 'Keine Beschreibung'),
            SizedBox(height: 20),
            Text(
              'Spieler in diesem Team:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: playerDocs.isEmpty
                  ? Text('Keine Spieler in diesem Team.')
                  : ListView.builder(
                      itemCount: playerDocs.length,
                      itemBuilder: (context, index) {
                        var player = playerDocs[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(player['name'][0].toUpperCase()),
                          ),
                          title: Text(player['name']),
                          subtitle: Text('Alter: ${player['age']}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
