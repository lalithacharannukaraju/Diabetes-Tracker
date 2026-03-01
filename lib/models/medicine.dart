import 'package:flutter/material.dart';

enum MedicineImportance { low, medium, high }

class Medicine {
  String id;
  String name;
  String dosage;
  TimeOfDay time;
  List<int> weekdays; // 1=Mon ... 7=Sun
  MedicineImportance importance;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.weekdays,
    this.importance = MedicineImportance.medium,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    final importanceStr = (json['importance'] as String? ?? 'medium').toLowerCase();
    MedicineImportance importance;
    switch (importanceStr) {
      case 'high':
        importance = MedicineImportance.high;
        break;
      case 'low':
        importance = MedicineImportance.low;
        break;
      default:
        importance = MedicineImportance.medium;
    }
    return Medicine(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      time: TimeOfDay(
        hour: json['timeHour'] as int,
        minute: json['timeMinute'] as int,
      ),
      weekdays: (json['weekdays'] as List<dynamic>).cast<int>(),
      importance: importance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'timeHour': time.hour,
      'timeMinute': time.minute,
      'weekdays': weekdays,
      'importance': importance.name,
    };
  }
}
