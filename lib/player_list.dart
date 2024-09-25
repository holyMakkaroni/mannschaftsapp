// lib/player_list.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'player_details.dart'; // Importiere PlayerDetails für die Anzeige von Spieler-Details
import 'app_drawer.dart'; // Importiere AppDrawer für das Navigationsmenü
import 'add_player_page.dart'; // Importiere AddPlayerPage
import 'edit_player_page.dart';

class PlayerList extends StatelessWidget {
  const PlayerList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Referenz auf die Firestore-Sammlung 'players'
    final CollectionReference playersRef =
        FirebaseFirestore.instance.collection('players');

    return Scaffold(
      appBar: AppBar(
        title: Text('Spielerliste'), // Titel der AppBar
        centerTitle: true, // Titel zentrieren
      ),
      drawer: AppDrawer(), // Füge das Navigationsmenü hinzu
      body: StreamBuilder<QuerySnapshot>(
        stream: playersRef
            .snapshots(), // Beobachte die Änderungen in der 'players'-Sammlung in Echtzeit
        builder: (context, snapshot) {
          // Fehlerbehandlung für das Laden der Daten
          if (snapshot.hasError) {
            return Center(child: Text('Fehler beim Laden der Spieler'));
          }

          // Ladeindikator anzeigen, solange die Daten geladen werden
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Wenn die Daten geladen sind, hole die Liste der Spieler-Dokumente
          final players = snapshot.data!.docs;

          // Wenn keine Spieler gefunden werden, zeige eine Nachricht an
          if (players.isEmpty) {
            return Center(child: Text('Keine Spieler gefunden'));
          }

          // Erstelle eine Liste der Spieler mit ListView.builder
          return ListView.builder(
            itemCount: players.length, // Anzahl der Spieler
            itemBuilder: (context, index) {
              var player = players[index]; // Hole den aktuellen Spieler

              return ListTile(
                leading: CircleAvatar(
                  // Zeige den ersten Buchstaben des Spielernamens im Avatar an
                  child: Text(player['name'][0].toUpperCase()),
                ),
                title: Text(player['name']), // Zeige den Namen des Spielers
                subtitle: Text(
                    'Alter: ${player['age']}'), // Zeige das Alter des Spielers
                onTap: () {
                  // Navigiere zur PlayerDetails-Seite, wenn der Spieler angeklickt wird
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerDetails(
                          player:
                              player), // Übergabe des Spieler-Dokuments an die Detailseite
                    ),
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons
                      .edit), // Stift-Symbol für das Bearbeiten des Spielers
                  onPressed: () {
                    // Navigiere zur EditPlayerPage beim Klick auf das Edit-Symbol
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPlayerPage(player: player),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigiere zur AddPlayerPage, wenn der "+"-Button geklickt wird
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddPlayerPage()), // Übergabe an die Seite zum Hinzufügen eines neuen Spielers
          );
        },
        child:
            Icon(Icons.add), // "+"-Icon für das Hinzufügen eines neuen Spielers
      ),
    );
  }
}
