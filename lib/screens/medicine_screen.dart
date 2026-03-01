import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/medicine.dart';
import 'all_medicines_screen.dart';

class MedicineScreen extends StatefulWidget {
  @override
  _MedicineScreenState createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  void _openAllPage() {
    Navigator.of(context).pushNamed(AllMedicinesScreen.routeName);
  }

  @override
  void initState() {
    super.initState();
    // Load medicines and today's taken status when this screen is first shown
    Future.microtask(() async {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.loadMedicines();
      await appState.refreshTakenStatus(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final now = DateTime.now();
    final todayList = appState.medicinesFor(now);

    return Scaffold(
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Today\'s medicines', style: Theme.of(context).textTheme.titleMedium),
                  Row(
                    children: [
                      TextButton(onPressed: _openAllPage, child: Text('All')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (appState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (todayList.isEmpty)
                const Text('No medicines scheduled for today')
              else
                ...todayList.map((m) {
                  final taken = appState.isTaken(m, now);
                  Color importanceColor;
                  switch (m.importance) {
                    case MedicineImportance.high:
                      importanceColor = Colors.redAccent;
                      break;
                    case MedicineImportance.medium:
                      importanceColor = Colors.orangeAccent;
                      break;
                    case MedicineImportance.low:
                      importanceColor = Colors.greenAccent;
                      break;
                  }
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: CheckboxListTile(
                      title: Text(m.name),
                      subtitle: Text('${m.dosage} at ${m.time.format(context)}'),
                      value: taken,
                      activeColor: importanceColor,
                      side: BorderSide(color: importanceColor, width: 2),
                      onChanged: (_) {
                        appState.toggleTaken(m, now);
                      },
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
