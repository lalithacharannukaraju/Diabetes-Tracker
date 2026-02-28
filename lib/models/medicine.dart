import 'package:flutter/material.dart';

enum MedicineImportance { low, medium, high }

class Medicine {
  String name;
  String dosage;
  TimeOfDay time;
  List<int> weekdays; // 1=Mon ... 7=Sun
  MedicineImportance importance;

  Medicine({
    required this.name,
    required this.dosage,
    required this.time,
    required this.weekdays,
    this.importance = MedicineImportance.medium,
  });
}
