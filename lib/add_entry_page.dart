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
  final CollectionReference cashEntriesRef =
      FirebaseFirestore.instance.collection('cash_entries');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neuen Eintrag hinzufügen'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Dropdown für Einnahme oder Ausgabe
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(
                    value: 'income',
                    child: Text('Einnahme'),
                  ),
                  DropdownMenuItem(
                    value: 'expense',
                    child: Text('Ausgabe'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    type = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Art'),
              ),
              // Datumsauswahl
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Datum',
                  hintText:
                      '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
              ),
              // Betrag
              TextFormField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Betrag'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte Betrag eingeben';
                  }
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return 'Ungültiger Betrag';
                  }
                  return null;
                },
                onSaved: (value) {
                  amount = double.parse(value!.replaceAll(',', '.'));
                },
              ),
              // Verwendungszweck
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Verwendungszweck'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte Verwendungszweck eingeben';
                  }
                  return null;
                },
                onSaved: (value) {
                  description = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Hinzufügen'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await cashEntriesRef.add({
                      'type': type,
                      'date': Timestamp.fromDate(selectedDate),
                      'amount': amount,
                      'description': description,
                    });
                    widget.onEntryAdded();
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
