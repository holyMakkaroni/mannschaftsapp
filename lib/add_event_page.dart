import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddEventPage extends StatefulWidget {
  final VoidCallback onEventAdded;

  const AddEventPage({super.key, required this.onEventAdded});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  String eventType = 'training';
  DateTime selectedDate = DateTime.now();
  String location = '';
  String matchup = ''; // Nur für Spieltermin
  TimeOfDay? selectedTime;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Termin hinzufügen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: eventType,
                items: const [
                  DropdownMenuItem(
                      value: 'training', child: Text('Trainingseinheit')),
                  DropdownMenuItem(value: 'game', child: Text('Spieltermin')),
                ],
                onChanged: (value) {
                  setState(() {
                    eventType = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Terminart'),
              ),
              if (eventType == 'game')
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Spielpaarung'),
                  onChanged: (value) {
                    matchup = value;
                  },
                  validator: (value) {
                    if (eventType == 'game' &&
                        (value == null || value.isEmpty)) {
                      return 'Bitte eine Spielpaarung eingeben';
                    }
                    return null;
                  },
                ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ort'),
                onChanged: (value) {
                  location = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte einen Ort eingeben';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != selectedDate) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: Text(
                    'Datum auswählen: ${DateFormat('dd.MM.yyyy').format(selectedDate)}'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime:
                        TimeOfDay(hour: 12, minute: 0), // Keine Vorauswahl
                  );
                  if (picked != null) {
                    setState(() {
                      selectedTime = picked;
                    });
                  }
                },
                child: Text(
                    'Uhrzeit auswählen: ${selectedTime != null ? selectedTime!.format(context) : 'Keine Uhrzeit ausgewählt'}'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await FirebaseFirestore.instance.collection('events').add({
                      'eventType': eventType,
                      'date': selectedDate,
                      'location': location,
                      'matchup': eventType == 'game' ? matchup : null,
                      'time': selectedTime != null
                          ? selectedTime!.format(context)
                          : null,
                      'notes': '',
                      'completed': false,
                    });
                    widget.onEventAdded();
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
