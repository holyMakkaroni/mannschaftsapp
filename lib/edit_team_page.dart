import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTeamPage extends StatefulWidget {
  final String teamId;
  final VoidCallback onTeamUpdated;

  const EditTeamPage(
      {Key? key, required this.teamId, required this.onTeamUpdated})
      : super(key: key);

  @override
  _EditTeamPageState createState() => _EditTeamPageState();
}

class _EditTeamPageState extends State<EditTeamPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  final CollectionReference teamsRef =
      FirebaseFirestore.instance.collection('teams');
  DocumentSnapshot? teamData;

  @override
  void initState() {
    super.initState();
    fetchTeamData();
  }

  Future<void> fetchTeamData() async {
    var teamSnapshot = await teamsRef.doc(widget.teamId).get();
    setState(() {
      teamData = teamSnapshot;
      name = teamData!['name'];
      description = teamData!['description'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (teamData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Team bearbeiten'),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Team bearbeiten'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Teamname
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Teamname'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte Teamname eingeben';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              // Beschreibung
              TextFormField(
                initialValue: description,
                decoration:
                    InputDecoration(labelText: 'Beschreibung (optional)'),
                onSaved: (value) {
                  description = value ?? '';
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Aktualisieren'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await teamsRef.doc(widget.teamId).update({
                      'name': name,
                      'description': description,
                    });
                    widget.onTeamUpdated();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
