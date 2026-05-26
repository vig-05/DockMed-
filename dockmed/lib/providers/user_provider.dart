import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String name = 'Guest';
  String dob = 'Not set';
  String gender = 'Not set';
  String bloodGroup = 'Not set';
  String height = '0';
  String weight = '0';
  String emergencyName = 'Not set';
  String emergencyRelation = 'Not set';
  String emergencyPhone = 'Not set';

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  UserProvider() {
    _loadProfile();
  }

  double get bmi {
    try {
      final h = double.parse(height) / 100;
      final w = double.parse(weight);
      if (h > 0) return w / (h * h);
    } catch (_) {}
    return 0.0;
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('user_name') ?? 'Guest';
    dob = prefs.getString('user_dob') ?? '';
    gender = prefs.getString('user_gender') ?? '';
    bloodGroup = prefs.getString('user_bloodGroup') ?? '';
    height = prefs.getString('user_height') ?? '';
    weight = prefs.getString('user_weight') ?? '';
    emergencyName = prefs.getString('user_emergencyName') ?? '';
    emergencyRelation = prefs.getString('user_emergencyRelation') ?? '';
    emergencyPhone = prefs.getString('user_emergencyPhone') ?? '';
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> updateUser({
    required String name,
    required String dob,
    required String gender,
    required String bloodGroup,
    required String height,
    required String weight,
    required String emergencyName,
    required String emergencyRelation,
    required String emergencyPhone,
  }) async {
    this.name = name;
    this.dob = dob;
    this.gender = gender;
    this.bloodGroup = bloodGroup;
    this.height = height;
    this.weight = weight;
    this.emergencyName = emergencyName;
    this.emergencyRelation = emergencyRelation;
    this.emergencyPhone = emergencyPhone;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_dob', dob);
    await prefs.setString('user_gender', gender);
    await prefs.setString('user_bloodGroup', bloodGroup);
    await prefs.setString('user_height', height);
    await prefs.setString('user_weight', weight);
    await prefs.setString('user_emergencyName', emergencyName);
    await prefs.setString('user_emergencyRelation', emergencyRelation);
    await prefs.setString('user_emergencyPhone', emergencyPhone);

    notifyListeners();
  }
}
