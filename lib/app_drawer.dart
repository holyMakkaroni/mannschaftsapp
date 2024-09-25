import 'package:flutter/material.dart';
import 'home_page.dart';
import 'player_list.dart';
import 'team_cash_page.dart';
import 'team_list.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Mannschafts App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Startseite'),
            onTap: () {
              Navigator.pop(context); // Schließt den Drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(title: 'Mannschafts App')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Spielerliste'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PlayerList()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Mannschaftskasse'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TeamCashPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text('Teams'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TeamList()),
              );
            },
          ),
        ],
      ),
    );
  }
}
