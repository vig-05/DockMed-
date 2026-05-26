import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VitalReading {
  final String id;
  final String type;
  final String displayValue;
  final double numericValue;
  final double? numericValue2; // e.g. for diastolic BP
  final DateTime date;

  VitalReading({
    required this.id,
    required this.type,
    required this.displayValue,
    required this.numericValue,
    this.numericValue2,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'displayValue': displayValue,
        'numericValue': numericValue,
        'numericValue2': numericValue2,
        'date': date.toIso8601String(),
      };

  factory VitalReading.fromJson(Map<String, dynamic> json) {
    return VitalReading(
      id: json['id'],
      type: json['type'],
      displayValue: json['displayValue'],
      numericValue: json['numericValue']?.toDouble() ?? 0.0,
      numericValue2: json['numericValue2']?.toDouble(),
      date: DateTime.parse(json['date']),
    );
  }
}

class VitalsProvider with ChangeNotifier {
  List<VitalReading> _readings = [];
  bool _isLoaded = false;

  List<VitalReading> get readings => _readings;
  bool get isLoaded => _isLoaded;

  VitalsProvider() {
    loadReadings();
  }

  Future<void> loadReadings() async {
    final prefs = await SharedPreferences.getInstance();
    final readingsJson = prefs.getStringList('vitals_readings');
    if (readingsJson != null) {
      _readings = readingsJson
          .map((json) => VitalReading.fromJson(jsonDecode(json)))
          .toList();
      _readings.sort((a, b) => b.date.compareTo(a.date));
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addReading(VitalReading reading) async {
    _readings.add(reading);
    _readings.sort((a, b) => b.date.compareTo(a.date));
    await _saveReadings();
    notifyListeners();
  }

  Future<void> _saveReadings() async {
    final prefs = await SharedPreferences.getInstance();
    final readingsJson =
        _readings.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList('vitals_readings', readingsJson);
  }

  VitalReading? getLatest(String type) {
    try {
      return _readings.firstWhere((r) => r.type == type);
    } catch (e) {
      return null;
    }
  }

  List<VitalReading> getHistory(String type) {
    final history = _readings.where((r) => r.type == type).toList();
    // sort chronological for charts (oldest to newest)
    history.sort((a, b) => a.date.compareTo(b.date));
    return history;
  }
}
