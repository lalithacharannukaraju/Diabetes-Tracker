import 'package:flutter/material.dart';

class GlucoseReading {
  String id;
  double value;
  String readingType; // fasting, post-meal, pre-meal, random
  DateTime date;
  TimeOfDay time;
  String notes;

  GlucoseReading({
    required this.id,
    required this.value,
    required this.readingType,
    required this.date,
    required this.time,
    this.notes = '',
  });

  factory GlucoseReading.fromJson(Map<String, dynamic> json) {
    return GlucoseReading(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      value: (json['value'] as num).toDouble(),
      readingType: (json['readingType'] as String? ?? 'random'),
      date: DateTime.parse(json['date'] as String),
      time: TimeOfDay(
        hour: json['timeHour'] as int,
        minute: json['timeMinute'] as int,
      ),
      notes: (json['notes'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'readingType': readingType,
      'timeHour': time.hour,
      'timeMinute': time.minute,
      'notes': notes,
    };
  }

  /// Returns a color based on the blood sugar value range
  Color get rangeColor {
    if (value < 70) return const Color(0xFFEF5350); // Low — red
    if (value <= 100) return const Color(0xFF66BB6A); // Normal fasting — green
    if (value <= 140) return const Color(0xFFFFCA28); // Borderline — yellow
    return const Color(0xFFEF5350); // High — red
  }

  String get rangeLabel {
    if (value < 70) return 'Low';
    if (value <= 100) return 'Normal';
    if (value <= 140) return 'Borderline';
    return 'High';
  }
}
