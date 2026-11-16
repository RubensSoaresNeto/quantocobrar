import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/budget.dart';
import '../models/professional_profile.dart';

class LocalStorage {
  static const _historyKey = 'budget_history';
  static const _profileKey = 'professional_profile';

  Future<List<Budget>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_historyKey) ?? [];
    return items
        .map(
          (item) => Budget.fromJson(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> saveBudget(Budget budget) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_historyKey) ?? [];
    items.insert(0, jsonEncode(budget.toJson()));
    await prefs.setStringList(_historyKey, items.take(30).toList());
  }

  Future<void> deleteBudget(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_historyKey) ?? [];
    if (index >= 0 && index < items.length) items.removeAt(index);
    await prefs.setStringList(_historyKey, items);
  }

  Future<ProfessionalProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_profileKey);
    if (value == null) return const ProfessionalProfile();
    return ProfessionalProfile.fromJson(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }

  Future<void> saveProfile(ProfessionalProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }
}
