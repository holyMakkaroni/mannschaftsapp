import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditEntryPage extends StatefulWidget {
  final DocumentSnapshot entry;
  final VoidCallback onEntryUpdated;

  const EditEntryPage(
      {super.key, required this.entry, required this.onEntryUpdated});

  @override
  _EditEntryPageState createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<EditEntryPage> {
  late String type;
  late DateTime selectedDate;
  late double amount;
  late String description;

  final _formKey = GlobalKey<FormState>();
  final CollectionReference cashEntriesRef =
      FirebaseFirestore.instance.collection('cash_entries');

  @override
  void initState() {
    super.initState();
    type = widget.entry['type'];
    selectedDate = widget.entry['date'].toDate();
    amount = widget.entry['amount'];
    description = widget.entry['description'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eintrag bearbeiten'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await widget.entry.reference.delete();
              widget.onEntryUpdated();
              Navigator.of(context).pop();
            },
          )
        ],
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
                initialValue: amount.toString(),
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
                initialValue: description,
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
                child: const Text('Aktualisieren'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await widget.entry.reference.update({
                      'type': type,
                      'date': Timestamp.fromDate(selectedDate),
                      'amount': amount,
                      'description': description,
                    });
                    widget.onEntryUpdated();
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
