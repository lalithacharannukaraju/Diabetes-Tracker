import 'package:flutter/material.dart';

class DietItem {
  String id;
  String text;
  TimeOfDay time;

  DietItem({
    required this.id,
    required this.text,
    required this.time,
  });

  factory DietItem.fromJson(Map<String, dynamic> json) {
    return DietItem(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      text: json['text'] as String,
      time: TimeOfDay(
        hour: (json['timeHour'] as int?) ?? 0,
        minute: (json['timeMinute'] as int?) ?? 0,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'timeHour': time.hour,
      'timeMinute': time.minute,
    };
  }
}
