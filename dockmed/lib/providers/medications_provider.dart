import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final Map<String, bool> timeSlots; // morning, afternoon, evening, night
  final DateTime startDate;
  final String notes;
  bool takenToday;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.timeSlots,
    required this.startDate,
    required this.notes,
    this.takenToday = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'timeSlots': timeSlots,
        'startDate': startDate.toIso8601String(),
        'notes': notes,
        'takenToday': takenToday,
      };

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      timeSlots: Map<String, bool>.from(json['timeSlots']),
      startDate: DateTime.parse(json['startDate']),
      notes: json['notes'] ?? '',
      takenToday: json['takenToday'] ?? false,
    );
  }
}

class MedicationsProvider with ChangeNotifier {
  List<Medication> _medications = [];
  bool _isLoaded = false;

  List<Medication> get medications => _medications;
  bool get isLoaded => _isLoaded;

  MedicationsProvider() {
    loadMedications();
  }

  Future<void> loadMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('medications_list');
    if (jsonList != null) {
      _medications = jsonList
          .map((json) => Medication.fromJson(jsonDecode(json)))
          .toList();
    }
    // Simple logic: if a new day has started, we reset 'takenToday'
    // To do this properly, we'd need to store the last opened date, 
    // but for now we just load what is saved.
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addMedication(Medication med) async {
    _medications.add(med);
    await _saveMedications();
    notifyListeners();
  }

  Future<void> deleteMedication(String id) async {
    _medications.removeWhere((m) => m.id == id);
    await _saveMedications();
    notifyListeners();
  }

  Future<void> toggleTakenToday(String id, bool taken) async {
    final idx = _medications.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _medications[idx].takenToday = taken;
      await _saveMedications();
      notifyListeners();
    }
  }

  Future<void> _saveMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList =
        _medications.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList('medications_list', jsonList);
  }
}
