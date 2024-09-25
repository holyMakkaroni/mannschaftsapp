import 'package:flutter/material.dart';
import 'app_drawer.dart'; // Import für den Drawer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_entry_page.dart';
import 'edit_entry_page.dart';

class TeamCashPage extends StatefulWidget {
  const TeamCashPage({super.key});

  @override
  _TeamCashPageState createState() => _TeamCashPageState();
}

class _TeamCashPageState extends State<TeamCashPage> {
  double totalAmount = 0.0;
  List<DocumentSnapshot> entries = [];
  bool isLoading = false;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;

  final CollectionReference cashEntriesRef =
      FirebaseFirestore.instance.collection('cash_entries');

  @override
  void initState() {
    super.initState();
    fetchTotalAmount();
    fetchEntries();
  }

  // Funktion zum Berechnen des Gesamtbetrags
  Future<void> fetchTotalAmount() async {
    double total = 0.0;
    QuerySnapshot snapshot = await cashEntriesRef.get();

    for (var doc in snapshot.docs) {
      double amount = doc['amount'];
      if (doc['type'] == 'income') {
        total += amount;
      } else if (doc['type'] == 'expense') {
        total -= amount;
      }
    }

    setState(() {
      totalAmount = total;
    });
  }

  // Funktion zum Laden der Einträge mit Pagination
  Future<void> fetchEntries() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    Query query = cashEntriesRef.orderBy('date', descending: true).limit(10);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    QuerySnapshot snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;
      entries.addAll(snapshot.docs);
    } else {
      hasMore = false;
    }

    setState(() {
      isLoading = false;
    });
  }

  // Funktion zum Hinzufügen eines neuen Eintrags
  void addNewEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddEntryPage(onEntryAdded: onEntryAdded)),
    );
  }

  // Callback nach Hinzufügen eines Eintrags
  void onEntryAdded() {
    setState(() {
      entries.clear();
      lastDocument = null;
      hasMore = true;
    });
    fetchTotalAmount();
    fetchEntries();
  }

  // Funktion zum Bearbeiten eines Eintrags
  void editEntry(DocumentSnapshot entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              EditEntryPage(entry: entry, onEntryUpdated: onEntryUpdated)),
    );
  }

  // Callback nach Aktualisierung eines Eintrags
  void onEntryUpdated() {
    setState(() {
      entries.clear();
      lastDocument = null;
      hasMore = true;
    });
    fetchTotalAmount();
    fetchEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mannschaftskasse'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Anzeige des aktuellen Betrags
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.green[100],
              child: ListTile(
                title: const Text(
                  'Aktueller Betrag',
                  style: TextStyle(fontSize: 20.0),
                ),
                subtitle: Text(
                  '€ ${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 32.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          // Liste der Einträge
          Expanded(
            child: ListView.builder(
              itemCount: entries.length + 1,
              itemBuilder: (context, index) {
                if (index == entries.length) {
                  // Ladeindikator oder Pagination
                  if (hasMore) {
                    fetchEntries();
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const Center(child: Text('Keine weiteren Einträge'));
                  }
                }
                var entry = entries[index];
                DateTime date = entry['date'].toDate();
                String formattedDate = '${date.day}.${date.month}.${date.year}';
                return ListTile(
                  leading: Icon(
                    entry['type'] == 'income'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color:
                        entry['type'] == 'income' ? Colors.green : Colors.red,
                  ),
                  title: Text(entry['description']),
                  subtitle: Text(formattedDate),
                  trailing: Text(
                    '€ ${entry['amount'].toStringAsFixed(2)}',
                    style: TextStyle(
                      color:
                          entry['type'] == 'income' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    editEntry(entry);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}
