import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTeamPage extends StatefulWidget {
  const AddTeamPage({Key? key}) : super(key: key);

  @override
  _AddTeamPageState createState() => _AddTeamPageState();
}

class _AddTeamPageState extends State<AddTeamPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';

  final CollectionReference teamsRef =
      FirebaseFirestore.instance.collection('teams');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Neues Team hinzufügen'),
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
                decoration:
                    InputDecoration(labelText: 'Beschreibung (optional)'),
                onSaved: (value) {
                  description = value ?? '';
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Hinzufügen'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await teamsRef.add({
                      'name': name,
                      'description': description,
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
