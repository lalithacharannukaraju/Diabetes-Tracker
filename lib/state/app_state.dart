import 'package:flutter/material.dart';
import '../models/medicine.dart';

class AppState extends ChangeNotifier {
  final List<Medicine> _medicines = [];
  final Map<DateTime, List<String>> _dietEntries = {};
  final Map<DateTime, Set<String>> _takenMedicines = {}; // keys by date -> set of identifiers

  List<Medicine> get medicines => List.unmodifiable(_medicines);

  void updateMedicine(int index, Medicine m) {
    if (index >= 0 && index < _medicines.length) {
      _medicines[index] = m;
      notifyListeners();
    }
  }

  void addMedicine(Medicine m) {
    _medicines.add(m);
    notifyListeners();
  }

  List<Medicine> medicinesFor(DateTime date) {
    final wd = date.weekday;
    return _medicines.where((m) => m.weekdays.contains(wd)).toList();
  }

  List<String> dietFor(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _dietEntries[key] ?? [];
  }

  void addDietEntry(DateTime date, String entry) {
    final key = DateTime(date.year, date.month, date.day);
    _dietEntries.putIfAbsent(key, () => []).add(entry);
    notifyListeners();
  }

  // medicine taken tracking
  String _medKey(Medicine m) => '${m.name}-${m.time.hour}-${m.time.minute}';

  bool isTaken(Medicine m, DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _takenMedicines[key]?.contains(_medKey(m)) ?? false;
  }

  void toggleTaken(Medicine m, DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    final set = _takenMedicines.putIfAbsent(key, () => <String>{});
    final medKey = _medKey(m);
    if (set.contains(medKey)) {
      set.remove(medKey);
    } else {
      set.add(medKey);
    }
    notifyListeners();
  }

  List<Medicine> missedMedicinesFor(DateTime date) {
    // A medicine is missed if it was scheduled for `date` but `isTaken` is false for that date.
    final scheduled = medicinesFor(date);
    return scheduled.where((m) => !isTaken(m, date)).toList();
  }
}
