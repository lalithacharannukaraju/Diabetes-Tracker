import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'add_medicine_screen.dart';

class AllMedicinesScreen extends StatelessWidget {
  static const routeName = '/all-medicines';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: Text('All Medicines')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C2C2C), Color(0xFF121212)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: appState.medicines.length,
            itemBuilder: (ctx, idx) {
              final m = appState.medicines[idx];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(m.name),
                  subtitle: Text('${m.dosage} at ${m.time.format(context)}\n' +
                      'Days: ${m.weekdays.map((d) => ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d-1]).join(', ')}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AddMedicineScreen.routeName,
                        arguments: {'medicine': m, 'index': idx},
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
