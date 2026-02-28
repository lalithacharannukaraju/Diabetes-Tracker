import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class MissedMedicinesScreen extends StatelessWidget {
  static const routeName = '/missed-medicines';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    // Missed yesterday
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final missedList = appState.missedMedicinesFor(yesterday);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Missed Yesterday', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
              ),
              if (missedList.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No missed medicines yesterday!', style: TextStyle(color: Colors.white54)),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: missedList.length,
                    itemBuilder: (ctx, idx) {
                      final m = missedList[idx];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                          title: Text(m.name),
                          subtitle: Text('${m.dosage} at ${m.time.format(context)}'),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
