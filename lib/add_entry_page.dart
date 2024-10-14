import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEntryPage extends StatefulWidget {
  final VoidCallback onEntryAdded;

  const AddEntryPage({super.key, required this.onEntryAdded});

  @override
  _AddEntryPageState createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  String type = 'income';
  DateTime selectedDate = DateTime.now();
  double amount = 0.0;
  String description = '';

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eintrag hinzufügen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Einnahme')),
                  DropdownMenuItem(value: 'expense', child: Text('Ausgabe')),
                ],
                onChanged: (value) {
                  setState(() {
                    type = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Typ'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Betrag'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0.0;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte einen Betrag eingeben';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Beschreibung'),
                onChanged: (value) {
                  description = value;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await FirebaseFirestore.instance.collection('entries').add({
                      'type': type,
                      'amount': amount,
                      'description': description,
                      'date': selectedDate,
                    });
                    widget.onEntryAdded();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Speichern'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
