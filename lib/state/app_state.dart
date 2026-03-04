import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../models/glucose_reading.dart';
import '../models/diet_item.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class AppState extends ChangeNotifier {
  final List<Medicine> _medicines = [];
  final Map<DateTime, List<DietItem>> _dietEntries = {};
  final Map<DateTime, Set<String>> _takenMedicines = {}; // keys by date -> set of medicine IDs
  final Map<DateTime, List<GlucoseReading>> _glucoseReadings = {};

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Medicine> get medicines => List.unmodifiable(_medicines);

  ApiClient _client(String token) => ApiClient(token: token);

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _normaliseDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<String?> _getToken() => AuthService().getToken();

  // ───────────────────────── MEDICINES ─────────────────────────

  Future<void> loadMedicines() async {
    final token = await _getToken();
    if (token == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _client(token).get('/api/medicines');
      if (data is List) {
        _medicines
          ..clear()
          ..addAll(data.map((e) => Medicine.fromJson(e as Map<String, dynamic>)));
      }
      // Re-schedule notifications whenever medicines are loaded
      await NotificationService().scheduleAllMedicineNotifications(_medicines);
    } catch (e) {
      _error = 'Failed to load medicines';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> upsertMedicine({required Medicine medicine, String? existingId}) async {
    final token = await _getToken();
    if (token == null) return;
    try {
      Map<String, dynamic> payload = medicine.toJson();
      dynamic response;
      if (existingId == null || existingId.isEmpty) {
        response = await _client(token).post('/api/medicines', body: payload);
        final created = Medicine.fromJson(response as Map<String, dynamic>);
        _medicines.add(created);
      } else {
        response = await _client(token).put('/api/medicines/$existingId', body: payload);
        final updated = Medicine.fromJson(response as Map<String, dynamic>);
        final index = _medicines.indexWhere((m) => m.id == existingId);
        if (index != -1) {
          _medicines[index] = updated;
        }
      }
      await NotificationService().scheduleAllMedicineNotifications(_medicines);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save medicine';
      notifyListeners();
    }
  }

  Future<void> refreshTakenStatus(DateTime date) async {
    final token = await _getToken();
    if (token == null) return;
    try {
      final keyStr = _dateKey(date);
      final data = await _client(token).get('/api/medicines/status', query: {'date': keyStr});
      final ids = (data['takenMedicineIds'] as List<dynamic>).cast<String>();
      final key = _normaliseDate(date);
      _takenMedicines[key] = ids.toSet();
      notifyListeners();
    } catch (e) {
      // ignore for now, keeps local state
    }
  }

  List<Medicine> medicinesFor(DateTime date) {
    final wd = date.weekday;
    return _medicines.where((m) => m.weekdays.contains(wd)).toList();
  }

  bool isTaken(Medicine m, DateTime date) {
    final key = _normaliseDate(date);
    return _takenMedicines[key]?.contains(m.id) ?? false;
  }

  Future<void> toggleTaken(Medicine m, DateTime date) async {
    final token = await _getToken();
    if (token == null) return;
    final key = _normaliseDate(date);
    final set = _takenMedicines.putIfAbsent(key, () => <String>{});
    try {
      final dateStr = _dateKey(date);
      final result = await _client(token).post('/api/medicines/${m.id}/toggle-taken', body: {'date': dateStr});
      final taken = result['taken'] as bool;
      if (taken) {
        set.add(m.id);
      } else {
        set.remove(m.id);
      }
      notifyListeners();
    } catch (e) {
      // if API fails, revert local optimistic change
    }
  }

  List<Medicine> missedMedicinesFor(DateTime date) {
    final scheduled = medicinesFor(date);
    return scheduled.where((m) => !isTaken(m, date)).toList();
  }

  Future<void> deleteMedicine(String id) async {
    final token = await _getToken();
    if (token == null) return;
    try {
      await _client(token).delete('/api/medicines/$id');
      _medicines.removeWhere((m) => m.id == id);
      await NotificationService().scheduleAllMedicineNotifications(_medicines);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete medicine';
      notifyListeners();
    }
  }

  // ───────────────────────── DIET ─────────────────────────

  List<DietItem> dietFor(DateTime date) {
    final key = _normaliseDate(date);
    return _dietEntries[key] ?? [];
  }

  Future<void> loadDietFor(DateTime date) async {
    final token = await _getToken();
    if (token == null) return;
    final key = _normaliseDate(date);
    try {
      final dateStr = _dateKey(date);
      final data = await _client(token).get('/api/diet', query: {'date': dateStr});
      if (data is List) {
        _dietEntries[key] =
            data.map<DietItem>((e) => DietItem.fromJson(e as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (e) {
      // ignore for now, leaves any local entries as-is
    }
  }

  Future<void> addDietEntry(DateTime date, String text, TimeOfDay time) async {
    final token = await _getToken();
    if (token == null) return;
    final key = _normaliseDate(date);
    try {
      final dateStr = _dateKey(date);
      final response = await _client(token).post('/api/diet', body: {
        'date': dateStr,
        'text': text,
        'timeHour': time.hour,
        'timeMinute': time.minute,
      });
      final item = DietItem.fromJson(response as Map<String, dynamic>);
      _dietEntries.putIfAbsent(key, () => []).add(item);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save diet entry';
      notifyListeners();
    }
  }

  Future<void> deleteDietEntry(String id, DateTime date) async {
    final token = await _getToken();
    if (token == null) return;
    final key = _normaliseDate(date);
    try {
      await _client(token).delete('/api/diet/$id');
      _dietEntries[key]?.removeWhere((d) => d.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete diet entry';
      notifyListeners();
    }
  }

  // ───────────────────────── GLUCOSE ─────────────────────────

  List<GlucoseReading> glucoseFor(DateTime date) {
    final key = _normaliseDate(date);
    return _glucoseReadings[key] ?? [];
  }

  Future<void> loadGlucoseFor(DateTime date) async {
    final token = await _getToken();
    if (token == null) return;
    final key = _normaliseDate(date);
    try {
      final dateStr = _dateKey(date);
      final data = await _client(token).get('/api/glucose', query: {'date': dateStr});
      if (data is List) {
        _glucoseReadings[key] =
            data.map<GlucoseReading>((e) => GlucoseReading.fromJson(e as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (e) {
      // ignore for now
    }
  }

  Future<void> addGlucoseReading({
    required DateTime date,
    required double value,
    required String readingType,
    required TimeOfDay time,
    String notes = '',
  }) async {
    final token = await _getToken();
    if (token == null) return;
    final key = _normaliseDate(date);
    try {
      final dateStr = _dateKey(date);
      final response = await _client(token).post('/api/glucose', body: {
        'date': dateStr,
        'value': value,
        'readingType': readingType,
        'timeHour': time.hour,
        'timeMinute': time.minute,
        'notes': notes,
      });
      final reading = GlucoseReading.fromJson(response as Map<String, dynamic>);
      _glucoseReadings.putIfAbsent(key, () => []).add(reading);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save glucose reading';
      notifyListeners();
    }
  }

  Future<void> deleteGlucoseReading(String id, DateTime date) async {
    final token = await _getToken();
    if (token == null) return;
    final key = _normaliseDate(date);
    try {
      await _client(token).delete('/api/glucose/$id');
      _glucoseReadings[key]?.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete glucose reading';
      notifyListeners();
    }
  }
}
