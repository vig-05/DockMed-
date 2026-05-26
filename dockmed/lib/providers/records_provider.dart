import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicalRecord {
  final String id;
  final String title;
  final String category;
  final DateTime date;
  final String notes;

  MedicalRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      notes: json['notes'] ?? '',
    );
  }
}

class RecordsProvider with ChangeNotifier {
  List<MedicalRecord> _records = [];
  bool _isLoaded = false;

  List<MedicalRecord> get records => _records;
  bool get isLoaded => _isLoaded;

  RecordsProvider() {
    loadRecords();
  }

  Future<void> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getStringList('medical_records');
    if (recordsJson != null) {
      _records = recordsJson
          .map((json) => MedicalRecord.fromJson(jsonDecode(json)))
          .toList();
      _records.sort((a, b) => b.date.compareTo(a.date));
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addRecord(MedicalRecord record) async {
    _records.add(record);
    _records.sort((a, b) => b.date.compareTo(a.date));
    await _saveRecords();
    notifyListeners();
  }

  Future<void> deleteRecord(String id) async {
    _records.removeWhere((r) => r.id == id);
    await _saveRecords();
    notifyListeners();
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson =
        _records.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList('medical_records', recordsJson);
  }
}
