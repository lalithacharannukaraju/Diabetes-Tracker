import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medicine.dart';
import '../state/app_state.dart';

class AddMedicineScreen extends StatefulWidget {
  static const routeName = '/add-medicine';

  final Medicine? existing;
  final int? index;

  AddMedicineScreen({this.existing, this.index});

  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _dosage = '';
  TimeOfDay _time = TimeOfDay.now();
  List<bool> _selectedWeekdays = List.filled(7, false);
  MedicineImportance _importance = MedicineImportance.medium;

  bool get isEditing => widget.existing != null;

  void _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) {
      setState(() {
        _time = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final days = <int>[];
    for (int i = 0; i < 7; i++) {
      if (_selectedWeekdays[i]) days.add(i + 1);
    }
    if (days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one weekday')),
      );
      return;
    }
    final newMed = Medicine(
      id: widget.existing?.id ?? '',
      name: _name,
      dosage: _dosage,
      time: _time,
      weekdays: days,
      importance: _importance,
    );
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.upsertMedicine(
      medicine: newMed,
      existingId: isEditing ? widget.existing?.id : null,
    );
    
    // If opened via bottom navigation, there might be nothing to pop
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // If we can't pop, we must be embedded in the HomeScreen tab.
      // Redirect back to the main Home tab (index 0).
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void initState() {
    super.initState();
    if (isEditing && widget.existing != null) {
      _name = widget.existing!.name;
      _dosage = widget.existing!.dosage;
      _time = widget.existing!.time;
      _importance = widget.existing!.importance;
      for (var d in widget.existing!.weekdays) {
        if (d >= 1 && d <= 7) _selectedWeekdays[d - 1] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medicine' : 'Add Medicine'),
        automaticallyImplyLeading: Navigator.of(context).canPop(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C2C2C), Color(0xFF121212)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Enter a name' : null,
                onSaved: (v) => _name = v ?? '',
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Dosage'),
                validator: (v) => v!.isEmpty ? 'Enter dosage' : null,
                onSaved: (v) => _dosage = v ?? '',
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Time: ${_time.format(context)}'),
                  TextButton(onPressed: _pickTime, child: Text('Change')),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MedicineImportance>(
                initialValue: _importance,
                decoration: const InputDecoration(labelText: 'Importance'),
                items: MedicineImportance.values.map((imp) {
                  return DropdownMenuItem(
                    value: imp,
                    child: Text(imp.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _importance = val);
                },
              ),
              const SizedBox(height: 16),
              const Text('Days of week'),
              Wrap(
                spacing: 8,
                children: List.generate(7, (i) {
                  return FilterChip(
                    label: Text(daysLabels[i]),
                    selected: _selectedWeekdays[i],
                    onSelected: (sel) {
                      setState(() {
                        _selectedWeekdays[i] = sel;
                      });
                    },
                  );
                }),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _save, child: Text('Save')),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
