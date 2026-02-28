import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../state/app_state.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final DateTime date = _selectedDay ?? DateTime.now();
    final diet = appState.dietFor(date);
    final meds = appState.medicinesFor(date);
    final takenMeds = meds.where((m) => appState.isTaken(m, date)).length;
    final totalMeds = meds.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C2C2C), Color(0xFF121212)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _selectedDay == null
                  ? Center(
                      child: Text('No day selected',
                          style: Theme.of(context).textTheme.titleMedium),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Diet entries',
                              style: Theme.of(context).textTheme.titleMedium),
                          if (diet.isEmpty) const Text('No diet entries recorded.') else ...diet.map((item) => ListTile(title: Text(item))),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Medicines ($takenMeds/$totalMeds taken)',
                                  style: Theme.of(context).textTheme.titleMedium),
                              if (totalMeds > 0)
                                CircularProgressIndicator(
                                  value: takenMeds / totalMeds,
                                  backgroundColor: Colors.grey.shade800,
                                  color: Colors.tealAccent,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (meds.isEmpty) const Text('No medicines scheduled.') else ...meds.map((m) => ListTile(
                                title: Text(m.name),
                                subtitle: Text(
                                    '${m.dosage} at ${m.time.format(context)}'),
                              )),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}
