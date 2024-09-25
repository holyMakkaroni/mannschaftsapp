import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPlayerPage extends StatefulWidget {
  const AddPlayerPage({Key? key}) : super(key: key);

  @override
  _AddPlayerPageState createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  int age = 0;
  List<String> selectedTeams = [];

  final CollectionReference playersRef =
      FirebaseFirestore.instance.collection('players');
  final CollectionReference teamsRef =
      FirebaseFirestore.instance.collection('teams');

  List<QueryDocumentSnapshot> teamList = [];

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    var teamsSnapshot = await teamsRef.get();
    setState(() {
      teamList = teamsSnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Neuen Spieler hinzufügen'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte Namen eingeben';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              // Alter
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Alter'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte Alter eingeben';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ungültiges Alter';
                  }
                  return null;
                },
                onSaved: (value) {
                  age = int.parse(value!);
                },
              ),
              // Teams auswählen
              teamList.isEmpty
                  ? CircularProgressIndicator()
                  : Expanded(
                      child: ListView(
                        children: teamList.map((team) {
                          return CheckboxListTile(
                            title: Text(team['name']),
                            value: selectedTeams.contains(team.id),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedTeams.add(team.id);
                                } else {
                                  selectedTeams.remove(team.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Hinzufügen'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await playersRef.add({
                      'name': name,
                      'age': age,
                      'teams': selectedTeams,
                    });
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
