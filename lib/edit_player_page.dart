// edit_player_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPlayerPage extends StatefulWidget {
  final DocumentSnapshot player;

  const EditPlayerPage({Key? key, required this.player}) : super(key: key);

  @override
  _EditPlayerPageState createState() => _EditPlayerPageState();
}

class _EditPlayerPageState extends State<EditPlayerPage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late int age;
  List<String> selectedTeamIds = [];

  final CollectionReference teamsRef =
      FirebaseFirestore.instance.collection('teams');

  @override
  void initState() {
    super.initState();
    name = widget.player['name'];
    age = widget.player['age'];
    selectedTeamIds = List<String>.from(widget.player['teams']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spieler bearbeiten'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete), // Mülleimer-Symbol für Löschen
            onPressed:
                _confirmDeletePlayer, // Bestätigungsdialog vor dem Löschen
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name des Spielers
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte einen Namen eingeben';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              // Alter des Spielers
              TextFormField(
                initialValue: age.toString(),
                decoration: InputDecoration(labelText: 'Alter'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null) {
                    return 'Bitte ein gültiges Alter eingeben';
                  }
                  return null;
                },
                onSaved: (value) {
                  age = int.parse(value!);
                },
              ),
              SizedBox(height: 20), // Abstand zwischen den Feldern

              // Teams als Checkbox-Liste
              StreamBuilder<QuerySnapshot>(
                stream: teamsRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator(); // Ladeindikator
                  }

                  final teams = snapshot.data!.docs;

                  return Expanded(
                    child: ListView(
                      children: teams.map((team) {
                        return CheckboxListTile(
                          title: Text(team['name']),
                          value: selectedTeamIds.contains(team.id),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedTeamIds.add(team.id); // Team hinzufügen
                              } else {
                                selectedTeamIds
                                    .remove(team.id); // Team entfernen
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              ),

              // Speichern-Button
              ElevatedButton(
                child: Text('Speichern'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Aktualisiere den Spieler in Firestore
                    await widget.player.reference.update({
                      'name': name,
                      'age': age,
                      'teams': selectedTeamIds,
                    });

                    Navigator.pop(context); // Kehre zur vorherigen Seite zurück
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Funktion zum Anzeigen eines Bestätigungsdialogs vor dem Löschen des Spielers
  void _confirmDeletePlayer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Spieler löschen'),
        content: Text('Möchtest du diesen Spieler wirklich löschen?'),
        actions: [
          TextButton(
            child: Text('Abbrechen'),
            onPressed: () {
              Navigator.of(context).pop(); // Schließe den Dialog
            },
          ),
          TextButton(
            child: Text('Löschen'),
            onPressed: () async {
              Navigator.of(context).pop(); // Schließe den Dialog
              await _deletePlayer(); // Lösche den Spieler
            },
          ),
        ],
      ),
    );
  }

  // Funktion zum Löschen des Spielers aus Firestore
  Future<void> _deletePlayer() async {
    // Lösche den Spieler aus der Datenbank
    await widget.player.reference.delete();

    // Optional: Lösche zugehörige Beziehungen in der 'teamPlayers'-Sammlung, falls vorhanden
    QuerySnapshot teamPlayerRelations = await FirebaseFirestore.instance
        .collection('teamPlayers')
        .where('playerId', isEqualTo: widget.player.id)
        .get();

    for (var relation in teamPlayerRelations.docs) {
      await relation.reference.delete(); // Lösche die Beziehungen
    }

    // Kehre zur vorherigen Seite zurück, nachdem der Spieler gelöscht wurde
    Navigator.pop(context);
  }
}
