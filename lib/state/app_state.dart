import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class AppState extends ChangeNotifier {
  final List<Medicine> _medicines = [];
  final Map<DateTime, List<String>> _dietEntries = {};
  final Map<DateTime, Set<String>> _takenMedicines = {}; // keys by date -> set of medicine IDs

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

  Future<String?> _getToken() => AuthService().getToken();

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
      final key = DateTime(date.year, date.month, date.day);
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

  List<String> dietFor(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _dietEntries[key] ?? [];
  }

  Future<void> loadDietFor(DateTime date) async {
    final token = await _getToken();
    if (token == null) return;
    final key = DateTime(date.year, date.month, date.day);
    try {
      final dateStr = _dateKey(date);
      final data = await _client(token).get('/api/diet', query: {'date': dateStr});
      if (data is List) {
        _dietEntries[key] =
            data.map<String>((e) => (e as Map<String, dynamic>)['text'] as String).toList();
        notifyListeners();
      }
    } catch (e) {
      // ignore for now, leaves any local entries as-is
    }
  }

  Future<void> addDietEntry(DateTime date, String entry) async {
    final token = await _getToken();
    if (token == null) return;
    final key = DateTime(date.year, date.month, date.day);
    try {
      final dateStr = _dateKey(date);
      await _client(token).post('/api/diet', body: {'date': dateStr, 'text': entry});
      _dietEntries.putIfAbsent(key, () => []).add(entry);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save diet entry';
      notifyListeners();
    }
  }

  bool isTaken(Medicine m, DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _takenMedicines[key]?.contains(m.id) ?? false;
  }

  Future<void> toggleTaken(Medicine m, DateTime date) async {
    final token = await _getToken();
    if (token == null) return;
    final key = DateTime(date.year, date.month, date.day);
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
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete medicine';
      notifyListeners();
    }
  }
}
