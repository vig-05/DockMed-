import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Appointment {
  final String id;
  final String doctorName;
  final String specialization;
  final String hospital;
  final DateTime dateTime;
  final String notes;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialization,
    required this.hospital,
    required this.dateTime,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctorName': doctorName,
        'specialization': specialization,
        'hospital': hospital,
        'dateTime': dateTime.toIso8601String(),
        'notes': notes,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      doctorName: json['doctorName'],
      specialization: json['specialization'],
      hospital: json['hospital'],
      dateTime: DateTime.parse(json['dateTime']),
      notes: json['notes'] ?? '',
    );
  }
}

class AppointmentsProvider with ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoaded = false;

  List<Appointment> get appointments => _appointments;
  bool get isLoaded => _isLoaded;

  AppointmentsProvider() {
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('appointments_list');
    if (jsonList != null) {
      _appointments = jsonList
          .map((json) => Appointment.fromJson(jsonDecode(json)))
          .toList();
      _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addAppointment(Appointment appt) async {
    _appointments.add(appt);
    _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    await _saveAppointments();
    notifyListeners();
  }

  Future<void> updateAppointment(Appointment updatedAppt) async {
    final idx = _appointments.indexWhere((a) => a.id == updatedAppt.id);
    if (idx != -1) {
      _appointments[idx] = updatedAppt;
      _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      await _saveAppointments();
      notifyListeners();
    }
  }

  Future<void> deleteAppointment(String id) async {
    _appointments.removeWhere((a) => a.id == id);
    await _saveAppointments();
    notifyListeners();
  }

  Future<void> _saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList =
        _appointments.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList('appointments_list', jsonList);
  }
}
