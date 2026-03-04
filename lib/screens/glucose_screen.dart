import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';


class GlucoseScreen extends StatefulWidget {
  @override
  _GlucoseScreenState createState() => _GlucoseScreenState();
}

class _GlucoseScreenState extends State<GlucoseScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AppState>(context, listen: false).loadGlucoseFor(_selectedDate);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await Provider.of<AppState>(context, listen: false).loadGlucoseFor(_selectedDate);
    }
  }

  Future<void> _addReading() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _AddGlucoseDialog(),
    );
    if (result != null) {
      await Provider.of<AppState>(context, listen: false).addGlucoseReading(
        date: _selectedDate,
        value: result['value'] as double,
        readingType: result['readingType'] as String,
        time: result['time'] as TimeOfDay,
        notes: result['notes'] as String,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final readings = appState.glucoseFor(_selectedDate);

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
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.bloodtype, color: Colors.redAccent.shade100, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Glucose Readings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                  ),
                ],
              ),
            ),
            if (readings.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bloodtype_outlined, size: 64, color: Colors.grey.shade700),
                      const SizedBox(height: 12),
                      Text(
                        'No readings for this day',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add your first reading',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: readings.length,
                  itemBuilder: (ctx, idx) {
                    final r = readings[idx];
                    return Dismissible(
                      key: ValueKey(r.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.redAccent),
                      ),
                      onDismissed: (_) {
                        Provider.of<AppState>(context, listen: false)
                            .deleteGlucoseReading(r.id, _selectedDate);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: r.rangeColor.withValues(alpha: 0.4), width: 1),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: r.rangeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${r.value.toInt()}',
                                style: TextStyle(
                                  color: r.rangeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            '${r.value.toInt()} mg/dL  •  ${r.rangeLabel}',
                            style: TextStyle(color: r.rangeColor, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${r.readingType.replaceAll('-', ' ').toUpperCase()}  •  ${r.time.format(context)}'
                            '${r.notes.isNotEmpty ? '\n${r.notes}' : ''}',
                          ),
                          isThreeLine: r.notes.isNotEmpty,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.black,
        onPressed: _addReading,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ──────────────────────── Add Glucose Dialog ────────────────────────

class _AddGlucoseDialog extends StatefulWidget {
  @override
  _AddGlucoseDialogState createState() => _AddGlucoseDialogState();
}

class _AddGlucoseDialogState extends State<_AddGlucoseDialog> {
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  String _readingType = 'random';
  TimeOfDay _time = TimeOfDay.now();

  static const _types = ['fasting', 'pre-meal', 'post-meal', 'random'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Glucose Reading'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Value (mg/dL)',
                prefixIcon: Icon(Icons.bloodtype),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _readingType,
              decoration: const InputDecoration(labelText: 'Reading Type'),
              items: _types
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.replaceAll('-', ' ').toUpperCase()),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _readingType = v);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Time: ${_time.format(context)}'),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _time,
                    );
                    if (picked != null) setState(() => _time = picked);
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final val = double.tryParse(_valueController.text.trim());
            if (val == null || val <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter a valid glucose value')),
              );
              return;
            }
            Navigator.pop(context, {
              'value': val,
              'readingType': _readingType,
              'time': _time,
              'notes': _notesController.text.trim(),
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
